require "net/http"

# HTTP client for radio-analyzer, the stateless service that identifies, analyzes
# and enriches songs. It never touches this database: SongAnalysis sends it what
# each step needs and stores the results.
class AnalyzerClient
  class Error < StandardError; end
  # The service isn't running (it's opt-in in docker-compose), can't be reached, or
  # is too overloaded to answer. Callers treat the song as not yet analyzed.
  class Unavailable < Error; end
  class MissingFile < Error; end
  # Essentia couldn't decode or analyze the file.
  class AnalysisFailed < Error; end

  class HTTPError < Error
    attr_reader :status

    def initialize(status, message)
      @status = status
      super("analyzer #{status}: #{message}")
    end
  end

  NETWORK_ERRORS = [
    Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, Errno::ENETUNREACH,
    Errno::ETIMEDOUT, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout, Net::ReadTimeout, EOFError
  ].freeze
  # What a proxy or load balancer answers when the service behind it is down.
  UNAVAILABLE_STATUSES = [502, 503, 504].freeze

  OPEN_TIMEOUT = 5
  # Requests queue behind the metadata APIs' rate limits and the Essentia pool.
  READ_TIMEOUT = 300

  def self.configured?
    ENV["ANALYZER_URL"].present?
  end

  def initialize(base_url = ENV.fetch("ANALYZER_URL"))
    @base_url = base_url
  end

  # => { "status", "mb_recording_id", "acoustid" }
  def identify(path:, title:, artist:, album: nil, duration: nil)
    post("/identify", { path:, title:, artist:, album:, duration: })
  end

  # => audio features, "styles", "style_tags", "sound_embedding", "model_version"
  def analyze(path:)
    post("/analyze", { path: })
  rescue HTTPError => e
    raise MissingFile, path if e.status == 404
    raise AnalysisFailed, e.message if e.status == 422
    raise
  end

  # => { "status", "sources", "release_year", "credits", "tags", and any found ids }
  def enrich(title:, artist:, album: nil, year: nil, id3_genre: nil, mb_recording_id: nil, discogs_master_id: nil)
    post("/enrich", { title:, artist:, album:, year:, id3_genre:, mb_recording_id:, discogs_master_id: })
  end

  # tags: [{ tag:, weight:, source: }] => { "embedding", "model_version" }
  def genre_embedding(tags)
    post("/genre-embedding", { tags: })
  end

  # => { "sound", "genre" } current model versions
  def versions
    @versions ||= request(Net::HTTP::Get.new(uri("/versions")))
  end

  private

  def post(path, body)
    req = Net::HTTP::Post.new(uri(path), "Content-Type" => "application/json")
    req.body = body.to_json
    request(req)
  end

  def request(req)
    u = req.uri
    response = Net::HTTP.start(u.host, u.port, use_ssl: u.scheme == "https",
                                               open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
      http.request(req)
    end
    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    status = response.code.to_i
    raise Unavailable, "#{@base_url}: HTTP #{status}" if UNAVAILABLE_STATUSES.include?(status)

    detail = JSON.parse(response.body)["detail"] rescue response.body
    raise HTTPError.new(status, detail)
  rescue *NETWORK_ERRORS => e
    raise Unavailable, "#{@base_url}: #{e.class}: #{e.message}"
  end

  def uri(path)
    URI.join(@base_url, path)
  end
end
