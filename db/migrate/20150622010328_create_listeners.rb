class CreateListeners < ActiveRecord::Migration
  def change
    create_table :listeners do |t|
      t.string :twitter_handle, unique: true
      t.index :twitter_handle

      t.timestamps null: false
    end
  end
end
