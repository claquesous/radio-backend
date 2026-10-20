require 'rails_helper'

RSpec.describe Artist, type: :model do
  it { should validate_presence_of(:name).with_message(/can't be blank/) }
  it { should have_many(:songs).dependent(:restrict_with_error) }
  it { should have_many(:albums).dependent(:restrict_with_error) }

  it "copies a hand-picked MusicBrainz id into mb_artist_id" do
    artist = create(:artist, musicbrainz_metadata: { "id" => "a74b1b7f-71a5-4011-9441-d0b5e4122711" })
    expect(artist.mb_artist_id).to eq("a74b1b7f-71a5-4011-9441-d0b5e4122711")
  end
end
