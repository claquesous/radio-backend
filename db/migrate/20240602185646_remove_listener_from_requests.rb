class RemoveListenerFromRequests < ActiveRecord::Migration[7.1]
  def change
    remove_reference :requests, :listener, null: false, foreign_key: true
  end
end
