require 'rails_helper'

RSpec.describe Chooser, type: :model do
  let(:user) { create(:user) }
  let(:stream) { create(:stream, user: user, enabled: true) }

  describe 'deletion prevention for enabled streams' do
    context 'when deletion would cause stream to have too few choosers' do
      let!(:choosers) { create_list(:chooser, Stream::MIN_CHOOSERS_REQUIRED, stream: stream) }

      it 'prevents deletion of the last required chooser' do
        chooser_to_delete = choosers.last
        expect { chooser_to_delete.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(chooser_to_delete.errors[:base]).to include("Cannot delete chooser: would violate stream requirements")
      end
    end

    context 'when deletion would not violate requirements' do
      before do
        create_list(:chooser, Stream::MIN_CHOOSERS_REQUIRED + 10, stream: stream)
      end

      it 'allows deletion when requirements are still met' do
        chooser_to_delete = stream.choosers.last
        expect { chooser_to_delete.destroy! }.not_to raise_error
      end
    end

    context 'when stream is not enabled' do
      let(:disabled_stream) { create(:stream, user: user, enabled: false) }
      let!(:chooser) { create(:chooser, stream: disabled_stream) }

      it 'allows deletion regardless of requirements' do
        expect { chooser.destroy! }.not_to raise_error
      end
    end

    context 'when deletion would cause artist to exceed limit' do
      let!(:artist) { create(:artist) }
      let!(:other_artist) { create(:artist) }
      let!(:artist_songs) { create_list(:song, Stream::MAX_ARTIST_CHOOSERS, artist: artist) }
      let!(:other_songs) { create_list(:song, Stream::MIN_CHOOSERS_REQUIRED - Stream::MAX_ARTIST_CHOOSERS + 1, artist: other_artist) }

      before do
        artist_songs.each { |song| create(:chooser, stream: stream, song: song) }
        other_songs.each { |song| create(:chooser, stream: stream, song: song) }
      end

      it 'allows deletion when it does not violate artist limits' do
        chooser_to_delete = stream.choosers.joins(:song).where('songs.artist_id = ?', other_artist.id).first
        expect { chooser_to_delete.destroy! }.not_to raise_error
      end
    end
  end
end
