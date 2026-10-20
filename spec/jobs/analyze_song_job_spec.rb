require 'rails_helper'

RSpec.describe AnalyzeSongJob do
  let(:song) { create(:song) }
  let(:analysis) { instance_double(SongAnalysis, run: nil) }

  before { allow(AnalyzerClient).to receive(:new).and_return(instance_double(AnalyzerClient)) }

  it "analyzes the song and refreshes creator embeddings" do
    allow(SongAnalysis).to receive(:new).with(song, client: anything, force: false).and_return(analysis)
    allow(CreatorEmbeddings).to receive(:rebuild!)
    described_class.perform_now(song.id)
    expect(analysis).to have_received(:run)
    expect(CreatorEmbeddings).to have_received(:rebuild!)
  end

  it "gives up quietly when the analyzer isn't running" do
    allow(SongAnalysis).to receive(:new).and_return(analysis)
    allow(analysis).to receive(:run).and_raise(AnalyzerClient::Unavailable, "connection refused")
    expect { described_class.perform_now(song.id) }.not_to raise_error
  end
end
