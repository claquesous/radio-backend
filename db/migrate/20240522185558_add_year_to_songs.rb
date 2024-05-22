class AddYearToSongs < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :year, :integer
  end
end
