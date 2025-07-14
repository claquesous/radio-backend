require 'rails_helper'

RSpec.describe Stream, type: :model do
  subject { build(:stream) }
  it { should have_many(:plays) }
  it { should have_many(:requests) }

  let(:stream) { create(:stream, default_featured: true) }

  describe "#next_play" do
    it "returns eligible requests first" do
      request = create(:request, stream: stream)
      stream.choosers = create_list(:chooser, 5) do |chooser, i|
        chooser.rating = 99
      end
      expect(stream.next_play.song.id).to eq(request.song.id)
    end

    it "returns songs with high ratings" do
      song = create(:song)
      stream.choosers = create_list(:chooser, 5) do |chooser, i|
        chooser.rating = i * 20
        chooser.song = song if i == 4
      end

      allow(Random).to receive(:rand).and_wrap_original do |original_method, *args|
        unless @called
          @called = true
          0.75
        else
          original_method.call(*args)
        end
      end

      expect(stream.next_play.song.id).to eq(song.id)
    end

    it "limits repeat artists" do
      artist = create(:artist)
      song = create(:song, artist: artist)

      stream.plays.create(song: song)
      create_list(:song, 4, artist: artist)
      new_song = create(:chooser, stream: stream, rating: 5).song

      expect(stream.choosers.count).to eq(6)
      expect(stream.next_play.song.id).to eq(new_song.id)
    end

    it "limits repeat songs" do
      song = create(:song)

      stream.plays.create(song: song)
      new_song = create(:chooser, stream: stream, rating: 5).song

      expect(stream.choosers.count).to eq(2)
      expect(stream.next_play.song.id).to eq(new_song.id)
    end
  end

  describe "validations" do
    it "does not allow enabled to be true on create" do
      stream = build(:stream, enabled: true)
      expect(stream).not_to be_valid
      expect(stream.errors[:enabled]).to include("cannot be true at creation")
    end

    it "does not allow destroy if enabled is true" do
      stream = create(:stream, enabled: false)
      stream.update(enabled: true)
      expect { stream.destroy }.not_to change(Stream, :count)
      expect(stream.errors[:base]).to include("Cannot destroy an enabled stream")
    end
  end

  describe "event publishing" do
    let(:stream) { create(:stream, enabled: false) }

    before do
      allow(StreamEventPublisher).to receive(:publish)
      allow_any_instance_of(Stream).to receive(:validate_chooser_set).and_return(true)
    end

    it "publishes stream_created when enabled goes from false to true" do
      stream.update(enabled: true)
      expect(StreamEventPublisher).to have_received(:publish).with(:stream_created, stream)
    end

    it "publishes stream_destroyed when enabled goes from true to false" do
      stream.update(enabled: true)
      stream.update(enabled: false)
      expect(StreamEventPublisher).to have_received(:publish).with(:stream_destroyed, stream)
    end

    it "publishes stream_updated when name changes for enabled stream" do
      stream.update(enabled: true)
      stream.update(name: "New Name")
      expect(StreamEventPublisher).to have_received(:publish).with(:stream_updated, stream)
    end

    it "publishes stream_updated when premium changes for enabled stream" do
      stream.update(enabled: true)
      stream.update(premium: true)
      expect(StreamEventPublisher).to have_received(:publish).with(:stream_updated, stream)
    end

    it "publishes stream_updated when description changes for enabled stream" do
      stream.update(enabled: true)
      stream.update(description: "desc")
      expect(StreamEventPublisher).to have_received(:publish).with(:stream_updated, stream)
    end

    it "publishes stream_updated when genre changes for enabled stream" do
      stream.update(enabled: true)
      stream.update(genre: "rock")
      expect(StreamEventPublisher).to have_received(:publish).with(:stream_updated, stream)
    end

    it "does not publish stream_updated when attributes change for disabled stream" do
      stream.update(name: "Other")
      expect(StreamEventPublisher).not_to have_received(:publish).with(:stream_updated, stream)
    end
  end

  describe 'playlist variety validation' do
    context 'when stream has fewer than the minimum required choosers' do
      let(:stream) { create(:stream, enabled: false) }
      before { create_list(:chooser, (120 - 1).to_i, stream: stream) }
      it 'is not valid' do
        stream.enabled = true
        expect(stream).not_to be_valid
        expect(stream.errors[:enabled]).to include("cannot be enabled: not enough playlist variety")
      end
    end

    context 'when stream has enough choosers but not enough variety' do
      let!(:artists) { create_list(:artist, 3) }
      it 'is not valid' do
        120.times do |i|
          create(:chooser, stream: stream, song: create(:song, artist: artists[i%3]))
        end
        stream.enabled = true
        expect(stream).not_to be_valid
        expect(stream.errors[:enabled]).to include("cannot be enabled: not enough playlist variety")
      end
    end

    it 'when stream meets all playlist variety requirements is valid' do
      create_list(:chooser, 120, stream: stream)
      stream.enabled = true
      expect(stream).to be_valid
    end
  end
end

