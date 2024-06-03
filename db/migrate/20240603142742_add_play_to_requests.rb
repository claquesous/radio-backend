class AddPlayToRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :requests, :play, null: true, foreign_key: true
  end
end
