class AddTweetIdToPlays < ActiveRecord::Migration
  def change
    add_column :plays, :tweet_id, :string
  end
end
