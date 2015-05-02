class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :play, index: true, foreign_key: true
      t.boolean :up
      t.string :twitter_handle

      t.timestamps null: false
    end
  end
end
