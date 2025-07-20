class AddMusicbrainzMetadataToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :musicbrainz_metadata, :jsonb
    add_index :artists, :musicbrainz_metadata, using: :gin
  end
end
