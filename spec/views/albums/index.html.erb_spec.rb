require 'rails_helper'

RSpec.describe "albums/index", type: :view do
  before(:each) do
    assign(:albums, [
      create(:album),
      create(:album),
    ])
  end

  it "renders a list of albums" do
    render
    assert_select "tr>td", :text => "Album Title".to_s, :count => 4
    assert_select "tr>td", :text => "album-title".to_s, :count => 2
  end
end
