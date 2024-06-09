class AddArtistNameOverrideToSong < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :artist_name_override, :string
  end
end
