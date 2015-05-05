class AddRatingFeaturedIndexToSongs < ActiveRecord::Migration
  def change
    add_index(:songs, [:rating, :featured])
  end
end
