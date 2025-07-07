class AddNonConditionalIndexToChoosers < ActiveRecord::Migration[8.0]
  def change
    add_index :choosers, [:stream_id, :rating], name: "index_choosers_on_stream_id_and_rating_unconditional"
  end
end
