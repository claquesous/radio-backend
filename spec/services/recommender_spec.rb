require 'rails_helper'

RSpec.describe Recommender do
  let(:seed) { create(:song_feature, sound: { 0 => 1.0 }, creators: { 7 => 1.0 }, genre: { 0 => 1.0 }, release_year: 1980) }

  def similar(weights, **options)
    Recommender.similar(seed.song, weights:, **options)
  end

  def similar_titles(weights, **options)
    similar(weights, **options).map { |result| result.song.title }
  end

  describe ".similar" do
    it "ranks by the weighted facet" do
      sounds_alike = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }, creators: { 7 => 0.1, 8 => 1.0 }).song
      same_producer = create(:song_feature, sound: { 0 => 0.1, 1 => 1.0 }, creators: { 7 => 1.0, 8 => 0.1 }).song

      expect(similar_titles({ sound: 1 })).to eq([sounds_alike.title, same_producer.title])
      expect(similar_titles({ creators: 1 })).to eq([same_producer.title, sounds_alike.title])
    end

    it "blends facets and reports calibrated scores and raw similarities" do
      create(:song_feature, sound: { 0 => 1.0 }, creators: { 9 => 1.0 })
      result = similar({ sound: 1, creators: 1 }).first
      expect(result.scores[:sound]).to be_within(0.001).of(1.0)
      expect(result.scores[:creators]).to eq(0.0)
      expect(result.score).to be_within(0.001).of(0.5)
      expect(result.details).to include(sound: be_within(0.001).of(1.0), creators: 0.0)
    end

    it "rescales each facet with its calibration before blending" do
      create(:facet_calibration, facet: "sound", p50: 0.5, p99: 0.9, p999: 0.95)
      create(:song_feature, sound: { 0 => 0.8, 1 => 0.6 })   # raw cosine 0.8
      result = similar({ sound: 1 }).first
      expect(result.details[:sound]).to be_within(0.001).of(0.8)
      expect(result.scores[:sound]).to be_within(0.001).of(0.5625)  # 0.75 * (0.8 - 0.5) / (0.9 - 0.5)
    end

    it "uses creator overlap uncalibrated" do
      create(:facet_calibration, facet: "creators", p50: 0.0, p99: 0.05, p999: 0.9)
      create(:song_feature, creators: { 7 => 0.3, 9 => 1.0 })
      result = similar({ creators: 1 }).first
      expect(result.scores[:creators]).to be_within(0.001).of(result.details[:creators])
    end

    it "credits creators only for people the songs actually share" do
      shares = create(:song_feature, creators: { 7 => 1.0, 8 => 1.0 }).song
      create(:song_feature, creators: { 8 => 1.0, 9 => 1.0 })
      expect(similar_titles({ creators: 1 })).to eq([shares.title])
    end

    describe "genre_era" do
      it "combines genre similarity and closeness in release year" do
        same_genre_same_year = create(:song_feature, genre: { 0 => 1.0 }, release_year: 1981).song
        same_genre_later = create(:song_feature, genre: { 0 => 1.0 }, release_year: 2010).song
        # A related genre in the same year beats the same genre three decades on.
        other_genre_same_year = create(:song_feature, genre: { 0 => 0.3, 1 => 1.0 }, release_year: 1980).song

        results = similar({ genre_era: 1 })
        expect(results.map(&:song)).to eq([same_genre_same_year, other_genre_same_year, same_genre_later])
        expect(results.first.details[:era]).to be > 0.9
        expect(results.last.details[:era]).to be < 0.01
      end

      it "uses year alone when the seed has no genre data" do
        seed.update!(genre_embedding: nil)
        near = create(:song_feature, release_year: 1982).song
        far = create(:song_feature, release_year: 2000).song
        expect(similar({ genre_era: 1 }).map(&:song)).to eq([near, far])
      end
    end

    it "omits songs with nothing in common" do
      create(:song_feature, creators: { 9 => 1.0 })
      expect(similar_titles({ creators: 1 })).to eq([])
    end

    it "excludes the seed song" do
      expect(similar_titles({ sound: 1 })).not_to include(seed.song.title)
    end

    it "limits candidates to a stream's chooser set" do
      stream = create(:stream)
      in_stream = create(:song_feature, sound: { 0 => 1.0, 1 => 0.5 }).song
      create(:song_feature, sound: { 0 => 1.0 })
      create(:chooser, stream:, song: in_stream)

      expect(similar_titles({ sound: 1 }, stream:)).to eq([in_stream.title])
    end

    it "gives a bonus to compatible keys and tempos" do
      seed.update!(key: 0, mode: "major", bpm: 120)
      compatible = create(:song_feature, sound: { 0 => 1.0, 1 => 0.3 }, key: 7, mode: "major", bpm: 60).song
      clashing = create(:song_feature, sound: { 0 => 1.0, 1 => 0.3 }, key: 6, mode: "major", bpm: 97).song

      expect(similar_titles({ sound: 1 })).to eq([compatible.title, clashing.title])
    end

    it "does not let the key/tempo bonus turn a below-typical pair into a match" do
      create(:facet_calibration, facet: "sound", p50: 0.5, p99: 0.9, p999: 0.95)
      seed.update!(key: 0, mode: "major", bpm: 120)
      create(:song_feature, sound: { 0 => 0.3, 1 => 1.0 }, key: 0, mode: "major", bpm: 120)  # raw ~0.29
      expect(similar({ sound: 1 })).to eq([])
    end

    it "keeps near-identical matches ranked instead of capping the bonus at 1" do
      create(:facet_calibration, facet: "sound", p50: 0.5, p99: 0.9, p999: 0.95)
      seed.update!(key: 0, mode: "major", bpm: 120)
      closer = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }, key: 0, mode: "major", bpm: 120).song
      further = create(:song_feature, sound: { 0 => 1.0, 1 => 0.2 }, key: 0, mode: "major", bpm: 120).song

      results = similar({ sound: 1 })
      expect(results.map(&:song)).to eq([closer, further])
      expect(results.first.scores[:sound]).to be < 1.0
      expect(results.first.scores[:sound]).to be > results.last.scores[:sound]
    end

    describe "artist policy" do
      let!(:same_artist) { create(:song_feature, sound: { 0 => 1.0 }, song: create(:song, artist: seed.song.artist)).song }

      it "excludes the seed's own artist by default" do
        expect(similar({ sound: 1 }).map(&:song)).to eq([])
        expect(similar({ sound: 1 }, same_artist: true).map(&:song)).to eq([same_artist])
      end

      it "takes at most per_artist songs from any one artist" do
        artist = create(:artist)
        best = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }, song: create(:song, artist:)).song
        second = create(:song_feature, sound: { 0 => 1.0, 1 => 0.2 }, song: create(:song, artist:)).song
        other = create(:song_feature, sound: { 0 => 1.0, 1 => 0.3 }).song

        expect(similar({ sound: 1 }).map(&:song)).to eq([best, other])
        expect(similar({ sound: 1 }, per_artist: 2).map(&:song)).to eq([best, second, other])
      end
    end

    describe "with several seeds" do
      let(:other_seed) { create(:song_feature, sound: { 1 => 1.0 }).song }

      it "ranks songs that suit every seed above songs that suit only one" do
        like_first = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }).song
        like_both = create(:song_feature, sound: { 0 => 1.0, 1 => 1.0 }).song

        results = Recommender.similar([seed.song, other_seed], weights: { sound: 1 })
        expect(results.map(&:song)).to eq([like_both, like_first])
        expect(results.map(&:song)).not_to include(seed.song, other_seed)
      end

      it "excludes every seed's artist" do
        create(:song_feature, sound: { 0 => 1.0, 1 => 1.0 }, song: create(:song, artist: other_seed.artist))
        expect(Recommender.similar([seed.song, other_seed], weights: { sound: 1 })).to eq([])
      end

      it "skips seeds that have not been analyzed" do
        match = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }).song
        expect(Recommender.similar([seed.song, create(:song)], weights: { sound: 1 }).map(&:song)).to eq([match])
      end
    end

    it "can exclude a stream's songs and given ids" do
      stream = create(:stream)
      in_stream = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }).song
      shown = create(:song_feature, sound: { 0 => 1.0, 1 => 0.2 }).song
      fresh = create(:song_feature, sound: { 0 => 1.0, 1 => 0.3 }).song
      create(:chooser, stream:, song: in_stream)

      expect(similar({ sound: 1 }, excluding_stream: stream, exclude_ids: [shown.id]).map(&:song)).to eq([fresh])
    end

    it "ignores facets the seed has no data for" do
      seed.update!(creator_embedding: nil)
      create(:song_feature, sound: { 0 => 1.0 })
      result = similar({ sound: 1, creators: 1 }).first
      expect(result.scores.keys).to eq([:sound])
    end

    it "returns nothing for a song that has not been analyzed" do
      expect(Recommender.similar(create(:song), weights: { sound: 1 })).to eq([])
    end
  end

  describe ".compatible_keys?" do
    it "accepts the same key, its relative minor, and fifth neighbors" do
      expect(Recommender.compatible_keys?(0, "major", 0, "major")).to be true
      expect(Recommender.compatible_keys?(0, "major", 9, "minor")).to be true   # C / Am
      expect(Recommender.compatible_keys?(0, "major", 7, "major")).to be true   # C / G
      expect(Recommender.compatible_keys?(0, "major", 5, "major")).to be true   # C / F
      expect(Recommender.compatible_keys?(4, "minor", 9, "minor")).to be true   # Em / Am
    end

    it "rejects distant keys and cross-mode neighbors" do
      expect(Recommender.compatible_keys?(0, "major", 6, "major")).to be false  # tritone
      expect(Recommender.compatible_keys?(0, "major", 4, "minor")).to be false  # C / Em
      expect(Recommender.compatible_keys?(nil, "major", 0, "major")).to be false
    end
  end

  describe ".compatible_tempos?" do
    it "accepts close, double and half tempos" do
      expect(Recommender.compatible_tempos?(120, 124)).to be true
      expect(Recommender.compatible_tempos?(120, 61)).to be true
      expect(Recommender.compatible_tempos?(120, 238)).to be true
      expect(Recommender.compatible_tempos?(120, 100)).to be false
      expect(Recommender.compatible_tempos?(nil, 100)).to be false
    end
  end
end
