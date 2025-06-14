require 'rails_helper'

RSpec.describe Play, type: :model do
  describe "associations" do
    
    
    
    
  end

  describe "validations" do
    
    
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

    
  end
end
