require 'rails_helper'

RSpec.describe "plays/index", type: :view do
  before(:each) do
    @play1 = create(:play)
    @play2 = create(:play, stream: @play1.stream)
    assign(:plays, [ @play1, @play2 ])
    assign(:stream, @play1.stream)
  end

  it "renders a list of plays" do
    render
    assert_select "tr>td", :text => @play1.song.title
    assert_select "tr>td", :text => @play2.song.title
  end
end
