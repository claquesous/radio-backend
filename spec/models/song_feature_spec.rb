require 'rails_helper'

RSpec.describe SongFeature, type: :model do
  subject { build(:song_feature) }
  it { should belong_to(:song) }
  it { should validate_inclusion_of(:mode).in_array(%w[major minor]).allow_nil }

  it "rejects keys outside 0..11" do
    subject.key = 12
    expect(subject).not_to be_valid
    subject.key = 0
    expect(subject).to be_valid
  end

  it "round-trips embeddings through pgvector" do
    feature = create(:song_feature, sound: { 3 => 1.0 })
    expect(feature.reload.sound_embedding.length).to eq(1280)
    expect(feature.sound_embedding[3]).to eq(1.0)
  end

  it "finds nearest neighbors by cosine distance" do
    target = create(:song_feature, sound: { 0 => 1.0 })
    near = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 })
    far = create(:song_feature, sound: { 1 => 1.0 })
    expect(target.nearest_neighbors(:sound_embedding, distance: "cosine").first(2)).to eq([near, far])
  end
end
