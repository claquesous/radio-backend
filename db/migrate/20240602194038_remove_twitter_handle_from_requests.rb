class RemoveTwitterHandleFromRequests < ActiveRecord::Migration[7.1]
  def change
    remove_column :requests, :twitter_handle, :string
  end
end
