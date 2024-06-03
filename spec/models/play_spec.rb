require 'rails_helper'

RSpec.describe Play, type: :model do
  describe "#resolve_requests" do
    it "marks requests as played" do
      request = create(:request)
      play = request.stream.next_play
      play.save!
      request.reload
      expect(request.play).to eq(play)
      expect(request.played).to be true
    end

    it "marks requests as played even if not eligible" do
      request = create(:request, requested_at: 1.minute.ago)
      play = request.stream.next_play # "randomly" picks the only song
      play.save!
      request.reload
      expect(request.play).to eq(play)
      expect(request.played).to be true
    end

    it "marks multiple requests as played" do
      request1 = create(:request)
      request2 = create(:request, stream: request1.stream, song: request1.song, requested_at: 1.minute.ago)
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
      old_play = create(:play)
      request = create(:request, played: true, play: old_play)
      new_play = request.stream.next_play
      new_play.save!
      request.reload
      expect(request.play).to eq(old_play)
    end
  end
end
