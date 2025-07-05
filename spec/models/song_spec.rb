require 'rails_helper'

RSpec.describe Song, type: :model do
  it { should validate_presence_of(:title).with_message(/can't be blank/) }
  it { should belong_to(:artist) }
  it { should belong_to(:album).optional }
  it { should have_many(:plays) }

  describe "before_destroy" do
    it "never allows destroy" do
      song = create(:song)
      expect(song.destroy).to be false
      expect(song.errors[:base]).to include("Songs cannot be deleted")
    end
  end
end
