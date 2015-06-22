class AddListerRefToRatings < ActiveRecord::Migration
  def change
    add_reference :ratings, :listener, index: true, foreign_key: true
  end
end
