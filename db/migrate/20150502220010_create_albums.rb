class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.references :artist, index: true, foreign_key: true
      t.string :title
      t.string :sort
      t.string :slug
      t.integer :tracks
      t.string :id3_genre
      t.string :record_label

      t.timestamps null: false
    end
  end
end
