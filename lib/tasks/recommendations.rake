namespace :recommendations do
  desc "Run pending songs through radio-analyzer, then refresh creator embeddings and calibrations. " \
       "SONG=1,2 (force those), LIMIT=n, RETRY=1 (retry failures and misses), THREADS=4"
  task analyze: :environment do
    client = AnalyzerClient.new
    retry_failed = ENV["RETRY"].present?
    force = ENV["SONG"].present?
    songs = if force
              Song.unscoped.where(id: ENV["SONG"].split(",")).order(:id)
            else
              SongAnalysis.pending(client.versions, retry_failed:)
            end
    songs = songs.limit(ENV["LIMIT"].to_i) if ENV["LIMIT"].present?
    songs = songs.includes(:artist, :album, :song_feature).to_a
    puts "analyzing #{songs.size} songs"

    # Concurrent requests keep the analyzer's Essentia pool busy; it serializes
    # the rate-limited metadata lookups itself.
    queue = Queue.new
    songs.each { |song| queue << song }
    done = Concurrent::AtomicFixnum.new
    failed = Concurrent::AtomicFixnum.new
    threads = Array.new(ENV.fetch("THREADS", 4).to_i) do
      Thread.new do
        while (song = queue.pop(true) rescue nil)
          Rails.application.executor.wrap do
            SongAnalysis.new(song, client:, force:, retry_failed:).run
          rescue AnalyzerClient::Unavailable
            raise
          rescue StandardError => e
            failed.increment
            warn "song #{song.id} #{song.title.inspect}: #{e.class}: #{e.message}"
          end
          count = done.increment
          puts "#{count}/#{songs.size}" if (count % 50).zero?
        end
      end
    end
    threads.each(&:join)
    puts "analyzed #{done.value - failed.value}, #{failed.value} failed"

    Rake::Task["recommendations:refresh"].invoke
  end

  desc "Rebuild creator embeddings and recalibrate every facet's similarity scale"
  task refresh: :environment do
    puts "creator embeddings: #{CreatorEmbeddings.rebuild!} songs"
    FacetCalibration.recalibrate!.each do |c|
      puts "calibration #{c.facet}: p50=#{c.p50.round(3)} p99=#{c.p99.round(3)} p999=#{c.p999.round(3)} " \
           "(#{c.sample_pairs} pairs)"
    end
  end
end
