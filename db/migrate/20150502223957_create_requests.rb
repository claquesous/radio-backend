class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :twitter_handle
      t.references :song, index: true, foreign_key: true
      t.datetime :requested_at
      t.boolean :played

      t.timestamps null: false
    end
  end
end
