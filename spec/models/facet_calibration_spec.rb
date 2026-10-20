require 'rails_helper'

RSpec.describe FacetCalibration, type: :model do
  subject { build(:facet_calibration, p50: 0.6, p99: 0.85, p999: 0.9) }
  it { should validate_presence_of(:facet) }

  it "maps the percentile anchors onto fixed scores" do
    expect(subject.normalize(0.6)).to eq(0.0)
    expect(subject.normalize(0.85)).to be_within(1e-9).of(0.75)
    expect(subject.normalize(0.9)).to be_within(1e-9).of(0.95)
    expect(subject.normalize(1.0)).to be_within(1e-9).of(1.0)
  end

  it "interpolates between anchors and keeps the top tail ordered" do
    expect(subject.normalize(0.725)).to be_within(1e-9).of(0.375)
    expect(subject.normalize(0.93)).to be > subject.normalize(0.91)
    expect(subject.normalize(0.95)).to be < 1.0
  end

  it "floors anything at or below a typical pair" do
    expect(subject.normalize(0.2)).to eq(0.0)
  end

  it "falls back to clamping when the anchors are degenerate" do
    expect(build(:facet_calibration, p50: 0.0, p99: 0.0, p999: 0.9).normalize(0.7)).to eq(0.7)
  end
end

RSpec.describe FacetCalibration, ".recalibrate!" do
  it "measures each facet's similarity percentiles over song pairs" do
    create(:song_feature, sound: { 0 => 1.0 }, sound_model_version: "v1")
    create(:song_feature, sound: { 0 => 1.0, 1 => 1.0 }, sound_model_version: "v1")
    create(:song_feature, sound: { 1 => 1.0 }, sound_model_version: "v1")

    calibrations = described_class.recalibrate!
    expect(calibrations.map(&:facet)).to eq(["sound"])
    sound = described_class.find_by!(facet: "sound")
    # Pair similarities: 0.707, 0, 0.707.
    expect(sound).to have_attributes(sample_pairs: 3, model_version: "v1")
    expect(sound.p50).to be_within(1e-3).of(0.707)
    expect(sound.p999).to be_within(1e-3).of(0.707)
  end

  it "samples pairs at random in a larger library" do
    6.times { |i| create(:song_feature, genre: { i => 1.0, 10 => 1.0 }) }
    described_class.recalibrate!(sample_pairs: 10)
    genre = described_class.find_by!(facet: "genre")
    expect(genre.sample_pairs).to be_between(1, 10)
    expect(genre.p50).to be_within(1e-3).of(0.5)
  end

  it "skips facets with fewer than two vectors" do
    create(:song_feature, creators: { 1 => 1.0 })
    expect(described_class.recalibrate!).to be_empty
  end
end
