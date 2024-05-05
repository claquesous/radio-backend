require 'rails_helper'

RSpec.describe "ratings/index", type: :view do
  before(:each) do
    assign(:ratings, [
      create(:rating),
      create(:rating),
    ])
  end

  it "renders a list of ratings" do
    render
    assert_select "tr>td", :text => true.to_s, :count => 2
    assert_select "tr>td", :text => "TwitterHandle".to_s, :count => 2
  end
end
