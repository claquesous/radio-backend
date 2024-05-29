class AddStreamToRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :requests, :stream, foreign_key: true
  end
end
