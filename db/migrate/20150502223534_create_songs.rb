class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.references :album, index: true, foreign_key: true
      t.references :artist, index: true, foreign_key: true
      t.string :title
      t.string :sort
      t.string :slug
      t.integer :track
      t.integer :time
      t.boolean :featured
      t.boolean :live
      t.boolean :remix
      t.float :rating
      t.string :path

      t.timestamps null: false
    end
  end
end
