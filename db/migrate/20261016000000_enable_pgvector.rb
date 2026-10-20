class EnablePgvector < ActiveRecord::Migration[8.0]
  # On RDS the migrating role needs rds_superuser for this.
  def change
    enable_extension "vector"
  end
end
