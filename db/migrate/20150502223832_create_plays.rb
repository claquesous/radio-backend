class CreatePlays < ActiveRecord::Migration
  def change
    create_table :plays do |t|
      t.references :song, index: true, foreign_key: true
      t.integer :ratings
      t.datetime :playtime

      t.timestamps null: false
    end
  end
end
