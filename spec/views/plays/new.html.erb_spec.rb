require 'rails_helper'

RSpec.describe "plays/new", type: :view do
  before(:each) do
    assign(:play, Play.new(
      :song => "",
      :ratings => 1
    ))
  end

  it "renders new play form" do
    render

    assert_select "form[action=?][method=?]", plays_path, "post" do

      assert_select "input#play_song[name=?]", "play[song]"

      assert_select "input#play_ratings[name=?]", "play[ratings]"
    end
  end
end
