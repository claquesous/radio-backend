# Analyzes one new or re-matched song, then refreshes creator embeddings (whose
# IDF spans the library). Facet calibration is left to `rake recommendations:analyze`
# and `recommendations:refresh`, since one song barely moves it.
class AnalyzeSongJob < ApplicationJob
  queue_as :default

  # The analyzer is opt-in; the next `rake recommendations:analyze` picks the song up.
  discard_on AnalyzerClient::Unavailable do |job, error|
    Rails.logger.warn("analyzer unavailable, skipping song #{job.arguments.first}: #{error.message}")
  end

  def perform(song_id, force: false)
    SongAnalysis.new(Song.unscoped.find(song_id), client: AnalyzerClient.new, force:).run
    CreatorEmbeddings.rebuild!
  end
end
