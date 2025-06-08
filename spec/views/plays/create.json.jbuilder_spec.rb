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
end
