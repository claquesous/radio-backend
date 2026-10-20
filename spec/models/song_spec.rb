require 'rails_helper'

RSpec.describe Song, type: :model do
  it { should validate_presence_of(:title).with_message(/can't be blank/) }
  it { should belong_to(:artist) }
  it { should belong_to(:album).optional }
  it { should have_many(:plays) }
  it { should have_one(:song_feature) }
  it { should have_many(:credits) }
  it { should have_many(:people).through(:credits) }
  it { should have_many(:song_tags) }

  describe "before_destroy" do
    it "never allows destroy" do
      song = create(:song)
      expect(song.destroy).to be false
      expect(song.errors[:base]).to include("Songs cannot be deleted")
    end
  end

  describe "musicbrainz_metadata" do
    let(:mbid) { "b1a9c0e9-d987-4042-ae91-78d6a3267d69" }

    it "copies a hand-picked recording id into mb_recording_id" do
      song = create(:song)
      song.update!(musicbrainz_metadata: { "id" => mbid, "title" => "x" })
      expect(song.reload.mb_recording_id).to eq(mbid)
    end

    it "ignores metadata without a valid id" do
      song = create(:song)
      song.update!(musicbrainz_metadata: { "id" => "nope" })
      expect(song.reload.mb_recording_id).to be_nil
    end

    it "queues the song for re-enrichment when the match changes" do
      feature = create(:song_feature, identify_status: "search", enriched_at: Time.current)
      feature.song.update!(musicbrainz_metadata: { "id" => mbid })
      expect(feature.reload).to have_attributes(identify_status: "manual", enriched_at: nil)
    end
  end

  describe "analysis" do
    include ActiveJob::TestHelper

    around do |example|
      previous = ENV["ANALYZER_URL"]
      ENV["ANALYZER_URL"] = "http://analyzer:8000"
      example.run
    ensure
      ENV["ANALYZER_URL"] = previous
    end

    it "queues a new song for analysis" do
      expect { create(:song) }.to have_enqueued_job(AnalyzeSongJob)
    end

    it "queues a song again when its recording match changes" do
      song = create(:song)
      expect { song.update!(musicbrainz_metadata: { "id" => "b1a9c0e9-d987-4042-ae91-78d6a3267d69" }) }
        .to have_enqueued_job(AnalyzeSongJob).with(song.id)
      expect { song.update!(rating: 10) }.not_to have_enqueued_job(AnalyzeSongJob)
    end

    it "skips bulk imports" do
      expect { Song.without_analysis { create(:song) } }.not_to have_enqueued_job(AnalyzeSongJob)
    end

    it "does nothing when no analyzer is configured" do
      ENV.delete("ANALYZER_URL")
      expect { create(:song) }.not_to have_enqueued_job(AnalyzeSongJob)
    end
  end
end
