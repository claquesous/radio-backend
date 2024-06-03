class RemoveTwitterHandleFromRatings < ActiveRecord::Migration[7.1]
  def change
    remove_column :ratings, :twitter_handle, :string
  end
end
