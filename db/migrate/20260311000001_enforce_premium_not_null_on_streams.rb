class EnforcePremiumNotNullOnStreams < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE streams SET premium = false WHERE premium IS NULL"
    change_column_null :streams, :premium, false
    change_column_default :streams, :premium, false
  end

  def down
    change_column_default :streams, :premium, nil
    change_column_null :streams, :premium, true
  end
end
