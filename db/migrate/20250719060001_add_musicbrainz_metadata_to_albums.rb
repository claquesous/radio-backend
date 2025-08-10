class AddMusicbrainzMetadataToAlbums < ActiveRecord::Migration[8.0]
  def change
    add_column :albums, :musicbrainz_metadata, :jsonb
    add_index :albums, :musicbrainz_metadata, using: :gin
  end
end
