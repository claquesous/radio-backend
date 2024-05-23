class AddUniqueAlbumIdTitleToSongs < ActiveRecord::Migration[7.1]
  def change
    add_index :songs, [:artist_id, :title], unique: true
  end
end
