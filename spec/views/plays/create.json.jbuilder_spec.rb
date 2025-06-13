require 'rails_helper'

RSpec.describe "plays/create", type: :view do
  before(:each) do
    @play = assign(:play, create(:play))
  end

  it "renders artist and song title for ices" do
    render
    expect(rendered).to match(@play.song.title)
    expect(rendered).to match(@play.artist.name)
  end

  it "renders gracefully if artist is missing" do
    @play.song.artist = nil
    @play.song.save!
    render
    expect(rendered).to match(@play.song.title)
  end

  it "renders gracefully if song is missing" do
    @play.song = nil
    render
    expect(rendered).not_to match(/.+/)
  end

  it "renders valid JSON" do
    render
    expect { JSON.parse(rendered) }.not_to raise_error
  end
end
