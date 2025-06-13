require 'rails_helper'

RSpec.describe Play, type: :model do
  describe "associations" do
    it { should belong_to(:song) }
    it { should belong_to(:artist) }
    it { should belong_to(:stream).optional }
    it { should have_many(:ratings) }
    it { should have_many(:requests) }
  end

  describe "validations" do
    it { should validate_presence_of(:song) }
    it { should validate_presence_of(:artist) }
  end

  describe "#resolve_requests" do
    let(:stream) { create(:stream) }
    let(:song) { create(:song) }

    it "marks requests as played" do
      request = create(:request, stream: stream, song: song)
      play = request.stream.next_play
      play.save!
      request.reload
      expect(request.play).to eq(play)
      expect(request.played).to be true
    end

    it "marks requests as played even if not eligible" do
      request = create(:request, stream: stream, song: song, requested_at: 1.minute.ago)
      play = request.stream.next_play # "randomly" picks the only song
      play.save!
      request.reload
      expect(request.play).to eq(play)
      expect(request.played).to be true
    end

    it "marks multiple requests as played" do
      request1 = create(:request, stream: stream, song: song)
      request2 = create(:request, stream: stream, song: song, requested_at: 1.minute.ago)
      play = request1.stream.next_play
      play.save!
      request1.reload
      request2.reload
      expect(request1.play).to eq(play)
      expect(request1.played).to be true
      expect(request2.play).to eq(play)
      expect(request2.played).to be true
    end

    it "does not mark previously played songs as played" do
      old_play = create(:play, stream: stream, song: song)
      request = create(:request, stream: stream, song: song, played: true, play: old_play)
      new_play = request.stream.next_play
      new_play.save!
      request.reload
      expect(request.play).to eq(old_play)
    end
  end
end
