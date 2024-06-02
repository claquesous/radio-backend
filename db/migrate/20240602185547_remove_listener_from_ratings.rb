class RemoveListenerFromRatings < ActiveRecord::Migration[7.1]
  def change
    remove_reference :ratings, :listener, null: false, foreign_key: true
  end
end
