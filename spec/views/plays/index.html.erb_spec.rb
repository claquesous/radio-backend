require 'rails_helper'

RSpec.describe "plays/index", type: :view do
  before(:each) do
    assign(:plays, [
      create(:play),
      create(:play),
    ])
  end

  it "renders a list of plays" do
    render
    assert_select "tr>td", :text => "Song Title".to_s, :count => 2
  end
end
