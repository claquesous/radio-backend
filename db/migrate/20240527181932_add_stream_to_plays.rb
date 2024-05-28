class AddStreamToPlays < ActiveRecord::Migration[7.1]
  def change
    add_reference :plays, :stream, foreign_key: true
  end
end
