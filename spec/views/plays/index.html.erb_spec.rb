require 'rails_helper'

RSpec.describe "plays/index", type: :view do
  before(:each) do
    assign(:plays, [
      Play.create!(
        :song => "",
        :ratings => 1
      ),
      Play.create!(
        :song => "",
        :ratings => 1
      )
    ])
  end

  it "renders a list of plays" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
