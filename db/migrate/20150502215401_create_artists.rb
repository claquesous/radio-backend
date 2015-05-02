class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.string :name
      t.string :sort
      t.string :slug
      t.index :name, unique: true

      t.timestamps null: false
    end
  end
end
