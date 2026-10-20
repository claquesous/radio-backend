class CreateSongTags < ActiveRecord::Migration[8.0]
  def change
    create_table :song_tags do |t|
      t.references :song, null: false, foreign_key: true
      t.string :tag, null: false
      t.float :weight, null: false, default: 1.0
      t.string :source, null: false
      t.timestamps
    end
    add_index :song_tags, [:song_id, :tag, :source], unique: true
    add_index :song_tags, :tag
  end
end
