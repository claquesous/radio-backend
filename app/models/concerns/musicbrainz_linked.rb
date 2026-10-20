# Keeps an mb_*_id column in step with a hand-picked match saved through the admin
# MusicBrainz search (musicbrainz_metadata), which SongAnalysis treats as authoritative.
module MusicbrainzLinked
  extend ActiveSupport::Concern

  UUID = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

  class_methods do
    def musicbrainz_id_column(column)
      before_save do
        next unless will_save_change_to_musicbrainz_metadata?
        mbid = musicbrainz_metadata.is_a?(Hash) ? musicbrainz_metadata["id"] : nil
        self[column] = mbid if mbid.to_s.match?(UUID)
      end
    end
  end
end
