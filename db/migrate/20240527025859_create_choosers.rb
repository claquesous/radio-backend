class CreateChoosers < ActiveRecord::Migration[7.1]
  def change
    create_table :choosers do |t|
      t.references :song, null: false, foreign_key: true
      t.references :stream, null: false, foreign_key: true
      t.boolean :featured
      t.float :rating

      t.timestamps
    end

    add_index :choosers, [:stream_id, :rating], where: "featured = true"
  end
end
