require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe "#latest_play" do
    it "doesn't allow ratings for earlier plays" do
      earlier = create(:play)
      create(:play, stream: earlier.stream)
      expect(build(:rating, play: earlier)).to_not be_valid
    end

    it "allows stream owner to rate earlier plays" do
      earlier = create(:play)
      create(:play, stream: earlier.stream)
      expect(build(:rating, play: earlier, user: earlier.stream.user)).to be_valid
    end
  end

  describe "#single_rating" do
    it "doesn't allow users to rate a play twice" do
      user = create(:user)
      play = create(:play)
      create(:rating, play: play, user: user)
      expect(build(:rating, play: play, user: user)).to_not be_valid
    end

    it "allows stream owner to rate multiple times" do
      stream = create(:stream)
      play = create(:play, stream: stream)
      create(:rating, play: play, user: stream.user)
      expect(build(:rating, play: play, user: stream.user)).to be_valid
    end
  end

  describe "#update_rating" do
    let(:play) { create(:play) }

    context "up" do
      it "upgrades middling songs a lot" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 50)
        create(:rating, play: play, up: true)
        expect(chooser.reload.rating).to be_within(0.001).of(55.0)
      end

      it "barely upgrades high rated songs" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 99)
        create(:rating, play: play, up: true)
        expect(chooser.reload.rating).to be_within(0.001).of(99.198)
      end
    end

    context "down" do
      it "downgrades middling songs a lot" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 50)
        create(:rating, play: play, up: false)
        expect(chooser.reload.rating).to be_within(0.001).of(45.0)
      end

      it "barely downgrades low rated songs" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 1)
        create(:rating, play: play, up: false)
        expect(chooser.reload.rating).to be_within(0.001).of(0.802)
      end
    end
  end
end
