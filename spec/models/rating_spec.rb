require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe "#update_rating" do
    let (:play) { create(:play) }

    context "up" do
      it "upgrades middling songs a lot" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 50)
        create(:rating, play: play, up: true)
        expect(chooser.reload.rating).to be(55.0)
      end

      it "barely upgrades high rated songs" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 99)
        create(:rating, play: play, up: true)
        expect(chooser.reload.rating).to be(99.198)
      end
    end

    context "down" do
      it "upgrades middling songs a lot" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 50)
        create(:rating, play: play, up: false)
        expect(chooser.reload.rating).to be(45.0)
      end

      it "barely upgrades low rated songs" do
        chooser = play.stream.choosers.where(song: play.song).first
        chooser.update!(rating: 1)
        create(:rating, play: play, up: false)
        expect(chooser.reload.rating).to be(0.802)
      end
    end
  end
end
