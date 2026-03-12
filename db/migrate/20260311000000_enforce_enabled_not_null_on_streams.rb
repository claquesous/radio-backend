class EnforceEnabledNotNullOnStreams < ActiveRecord::Migration[8.0]
  def up
    # Backfill any nulls before adding the constraint
    execute "UPDATE streams SET enabled = false WHERE enabled IS NULL"
    change_column_null :streams, :enabled, false
    change_column_default :streams, :enabled, false
  end

  def down
    change_column_default :streams, :enabled, nil
    change_column_null :streams, :enabled, true
  end
end
