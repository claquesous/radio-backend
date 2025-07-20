class AddMusicbrainzMetadataToSongs < ActiveRecord::Migration[8.0]
  def change
    add_column :songs, :musicbrainz_metadata, :jsonb
    add_index :songs, :musicbrainz_metadata, using: :gin
  end
end
