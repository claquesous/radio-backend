require 'rails_helper'

RSpec.describe CreatorEmbeddings do
  def overlap(a, b)
    a.sum { |person, weight| weight * b.fetch(person, 0.0) }
  end

  describe ".compute" do
    it "makes similarity exactly the shared credits" do
      vectors = described_class.compute([[1, 100, "producer"], [1, 1, "producer"], [2, 100, "producer"],
                                         [2, 2, "producer"], [3, 3, "producer"], [3, 4, "producer"]])
      expect(vectors.keys).to contain_exactly(1, 2, 3)
      vectors.each_value { |v| expect(v.values.sum { |w| w * w }).to be_within(1e-9).of(1.0) }
      expect(overlap(vectors[1], vectors[2])).to be > 0.3
      expect(overlap(vectors[1], vectors[3])).to eq(0.0)
    end

    it "weighs a shared producer above a shared engineer" do
      vectors = described_class.compute([[1, 100, "producer"], [2, 100, "producer"],
                                         [1, 200, "engineer"], [3, 200, "engineer"],
                                         [1, 1, "performer"], [2, 2, "performer"], [3, 3, "performer"]])
      expect(overlap(vectors[1], vectors[2])).to be > overlap(vectors[1], vectors[3])
    end

    it "counts prolific people for less" do
      credits = (1..10).map { |song| [song, 100, "producer"] } + [[1, 7, "producer"], [2, 7, "producer"]]
      vectors = described_class.compute(credits)
      expect(vectors[1][7]).to be > vectors[1][100]
    end

    it "handles an empty library" do
      expect(described_class.compute([])).to eq({})
    end
  end

  describe ".rebuild!" do
    it "writes vectors for songs with credits and clears songs that lost theirs" do
      producer = create(:person)
      a = create(:credit, person: producer).song
      b = create(:credit, person: producer).song
      stale = create(:song_feature, creators: { 5 => 1.0 })

      expect(described_class.rebuild!).to eq(2)
      expect(a.reload.song_feature).to have_attributes(creator_model_version: "tfidf-sparse-v1")
      expect(a.song_feature.creator_embedding.indices).to eq([producer.id])
      expect(b.reload.song_feature.creator_embedding).to be_present
      expect(stale.reload.creator_embedding).to be_nil
    end
  end
end
