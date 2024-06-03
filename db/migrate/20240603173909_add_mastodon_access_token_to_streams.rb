class AddMastodonAccessTokenToStreams < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :encrypted_mastodon_access_token, :string
    add_column :streams, :encrypted_mastodon_access_token_iv, :string
    add_column :streams, :mastodon_url, :string
    add_index :streams, :encrypted_mastodon_access_token_iv, unique: true
  end
end
