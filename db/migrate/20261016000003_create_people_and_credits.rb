class CreatePeopleAndCredits < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.uuid :mb_artist_id
      t.integer :discogs_id
      t.timestamps
    end
    add_index :people, :mb_artist_id, unique: true, where: "mb_artist_id IS NOT NULL"
    add_index :people, :discogs_id, unique: true, where: "discogs_id IS NOT NULL"
    add_index :people, :name

    create_table :credits do |t|
      t.references :song, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :role, null: false
      t.string :detail        # instrument name, "lead vocals", etc.
      t.string :source, null: false
      t.timestamps
    end
    add_index :credits, [:song_id, :person_id, :role, :source], unique: true
    add_index :credits, [:person_id, :role]
  end
end
