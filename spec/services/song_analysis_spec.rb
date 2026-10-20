require 'rails_helper'

RSpec.describe SongAnalysis do
  let(:recording) { "b1a9c0e9-d987-4042-ae91-78d6a3267d69" }
  let(:artist_mbid) { "c4b8f1e2-0a3d-4f5e-9b6c-7d8e9f0a1b2c" }
  let(:album) { create(:album, title: "Substance", id3_genre: "Rock") }
  let(:song) { create(:song, title: "Atmosphere", album:, artist: album.artist, path: "/music/a.mp3", year: 1988) }
  let(:client) { instance_double(AnalyzerClient, versions: { "sound" => "effnet-1", "genre" => "bge-1" }) }

  let(:analysis) do
    { "bpm" => 120.0, "bpm_confidence" => 3.1, "key" => 9, "mode" => "minor", "key_strength" => 0.8,
      "loudness" => -9.0, "danceability" => 1.1, "styles" => { "Rock---Post-Punk" => 0.9 },
      "style_tags" => { "post-punk" => 0.9, "rock" => 0.45 }, "sound_embedding" => SpecVectors.vec(1280, 0 => 1.0),
      "model_version" => "effnet-1" }
  end
  let(:enrichment) do
    { "status" => "musicbrainz", "sources" => ["musicbrainz"], "release_year" => 1980,
      "credits" => [{ "name" => "Martin Hannett", "mb_artist_id" => artist_mbid, "discogs_id" => nil,
                      "role" => "producer", "detail" => nil, "source" => "musicbrainz" }],
      "tags" => { "musicbrainz" => { "post-punk" => 1.0 }, "id3" => { "rock" => 1.0 } },
      "mb_work_ids" => [], "mb_artist_id" => artist_mbid }
  end

  before do
    allow(client).to receive(:identify).and_return(
      { "status" => "acoustid", "mb_recording_id" => recording, "acoustid" => nil })
    allow(client).to receive(:analyze).and_return(analysis)
    allow(client).to receive(:enrich).and_return(enrichment)
    allow(client).to receive(:genre_embedding).and_return(
      { "embedding" => SpecVectors.vec(384, 0 => 1.0), "model_version" => "bge-1" })
  end

  def run(**options)
    described_class.new(song.reload, client:, **options).run
  end

  it "runs every step and stores the results" do
    feature = run

    expect(client).to have_received(:identify).with(
      path: "/music/a.mp3", title: "Atmosphere", artist: album.artist.name, album: "Substance", duration: 180)
    expect(client).to have_received(:enrich).with(hash_including(mb_recording_id: recording, id3_genre: "Rock"))
    expect(song.reload.mb_recording_id).to eq(recording)
    expect(feature).to have_attributes(identify_status: "acoustid", bpm: 120.0, key: 9, mode: "minor",
                                       sound_model_version: "effnet-1", release_year: 1980,
                                       enrichment_status: "musicbrainz", genre_model_version: "bge-1")
    expect(feature.sound_embedding).to be_present
    expect(song.song_tags.pluck(:source, :tag)).to contain_exactly(
      %w[essentia post-punk], %w[essentia rock], %w[musicbrainz post-punk], %w[id3 rock])
    expect(song.credits.map { |c| [c.person.name, c.role] }).to eq([["Martin Hannett", "producer"]])
    expect(song.artist.reload.mb_artist_id).to eq(artist_mbid)
  end

  it "skips steps that are already done" do
    run
    run
    expect(client).to have_received(:identify).once
    expect(client).to have_received(:analyze).once
    expect(client).to have_received(:enrich).once
    expect(client).to have_received(:genre_embedding).once
  end

  it "re-analyzes after a sound model upgrade" do
    run
    allow(client).to receive(:versions).and_return({ "sound" => "effnet-2", "genre" => "bge-1" })
    run
    expect(client).to have_received(:analyze).twice
  end

  it "never second-guesses a hand-picked recording" do
    song.update!(musicbrainz_metadata: { "id" => recording })
    expect(run.identify_status).to eq("manual")
    expect(client).not_to have_received(:identify)
  end

  it "keeps the earlier match when identification errors" do
    song.update_columns(mb_recording_id: recording)
    allow(client).to receive(:identify).and_return({ "status" => "error", "mb_recording_id" => nil, "acoustid" => nil })
    expect(run.identify_status).to eq("error")
    expect(song.reload.mb_recording_id).to eq(recording)
  end

  it "records a failed analysis and doesn't retry it unless asked" do
    allow(client).to receive(:analyze).and_raise(AnalyzerClient::AnalysisFailed, "bad mp3")
    expect(run.sound_model_version).to eq("failed")
    run
    expect(client).to have_received(:analyze).once
    run(retry_failed: true)
    expect(client).to have_received(:analyze).twice
  end

  it "leaves a source's credits alone when enrichment didn't reach it" do
    discogs = create(:credit, song:, source: "discogs")
    run
    expect(song.credits.reload).to include(discogs)
  end

  it "records an enrichment error" do
    allow(client).to receive(:enrich).and_return({ "status" => "error" })
    expect(run).to have_attributes(enrichment_status: "error", enriched_at: be_present)
  end

  it "doesn't overwrite an artist id that is already set" do
    other = "d5c9a2f3-1b4e-4a6f-8c7d-9e0f1a2b3c4d"
    song.artist.update_columns(mb_artist_id: other)
    run
    expect(song.artist.reload.mb_artist_id).to eq(other)
  end

  describe ".pending" do
    let(:versions) { client.versions }

    it "lists songs with any step outstanding" do
      done = create(:song_feature, identify_status: "acoustid", analyzed_at: Time.current,
                                   sound_model_version: "effnet-1", enriched_at: Time.current).song
      fresh = create(:song)
      stale = create(:song_feature, identify_status: "acoustid", analyzed_at: Time.current,
                                    sound_model_version: "effnet-0", enriched_at: Time.current).song
      failed = create(:song_feature, identify_status: "acoustid", analyzed_at: Time.current,
                                     sound_model_version: "failed", enriched_at: Time.current).song
      unmatched = create(:song_feature, identify_status: "unmatched", analyzed_at: Time.current,
                                        sound_model_version: "effnet-1", enriched_at: Time.current).song
      unanalyzed = create(:song_feature, identify_status: "acoustid", enriched_at: Time.current).song

      expect(described_class.pending(versions)).to contain_exactly(fresh, stale, unanalyzed)
      expect(described_class.pending(versions, retry_failed: true))
        .to contain_exactly(fresh, stale, failed, unmatched, unanalyzed)
      expect(described_class.pending(versions, retry_failed: true)).not_to include(done)
    end
  end
end
