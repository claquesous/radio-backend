require 'rails_helper'

RSpec.describe "plays/edit", type: :view do
  before(:each) do
    @play = assign(:play, Play.create!(
      :song => "",
      :ratings => 1
    ))
  end

  it "renders the edit play form" do
    render

    assert_select "form[action=?][method=?]", play_path(@play), "post" do

      assert_select "input#play_song[name=?]", "play[song]"

      assert_select "input#play_ratings[name=?]", "play[ratings]"
    end
  end
end
