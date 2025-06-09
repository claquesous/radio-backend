require 'rails_helper'

RSpec.describe "songs/index", type: :view do
  before(:each) do
    assign(:songs, [
      create(:song),
      create(:song),
    ])
  end

  xit "renders a list of songs" do
    render
    assert_select "tr>td", :text => "Album Title".to_s, :count => 2
  end
end
