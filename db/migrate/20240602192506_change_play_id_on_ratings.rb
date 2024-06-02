class ChangePlayIdOnRatings < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ratings, :play_id, false
  end
end
