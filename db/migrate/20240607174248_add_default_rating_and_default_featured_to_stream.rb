class AddDefaultRatingAndDefaultFeaturedToStream < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :default_rating, :float, null: false, default: 50.0
    add_column :streams, :default_featured, :boolean, null: false, default: false
  end
end
