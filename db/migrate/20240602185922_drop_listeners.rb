class DropListeners < ActiveRecord::Migration[7.1]
  def change
    drop_table :listeners
  end
end
