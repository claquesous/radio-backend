require 'rails_helper'

RSpec.describe Stream, type: :model do
  let(:stream) { create(:stream) }

  describe "#next_play" do
    it "returns eligible requests first" do
      request = create(:request, stream: stream)
      stream.choosers = create_list(:chooser, 5) do |chooser, i|
        chooser.rating = 99
      end
      expect(stream.next_play.song.id).to equal(request.song.id)
    end

    it "returns songs with high ratings" do
      song = create(:song)
      stream.choosers = create_list(:chooser, 5) do |chooser, i|
        chooser.rating = i*20
        chooser.song = song if i==4
      end

      allow(Random).to receive(:rand).and_wrap_original do |original_method, *args|
        unless @called
          @called = true
          0.75
        else
          original_method.call(*args)
        end
      end

      expect(stream.next_play.song.id).to equal(song.id)
    end

    it "limits repeat artists" do
      artist = create(:artist)
      song = create(:song, artist: artist)

      stream.plays.create(song: song)
      create_list(:song, 4, artist: artist)
      new_song = create(:chooser, rating: 5).song

      expect(stream.choosers.count).to equal(6)
      expect(stream.next_play.song.id).to equal(new_song.id)
    end

    it "limits repeat songs" do
      song = create(:song)

      stream.plays.create(song: song)
      new_song = create(:chooser, rating: 5).song

      expect(stream.choosers.count).to equal(2)
      expect(stream.next_play.song.id).to equal(new_song.id)
    end
  end
end
