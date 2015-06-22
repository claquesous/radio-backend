class AddListerRefToRequests < ActiveRecord::Migration
  def change
    add_reference :requests, :listener, index: true, foreign_key: true
  end
end
