class AddPremiumGenreDescriptionEnabledToStream < ActiveRecord::Migration[8.0]
  def change
    add_column :streams, :premium, :boolean
    add_column :streams, :genre, :string
    add_column :streams, :description, :text
    add_column :streams, :enabled, :boolean
  end
end
