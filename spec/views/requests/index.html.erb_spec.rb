require 'rails_helper'

RSpec.describe "requests/index", type: :view do
  before(:each) do
    assign(:requests, [
      create(:request),
      create(:request),
    ])
  end

  it "renders a list of requests" do
    render
    assert_select "tr>td", :text => "TwitterHandle".to_s, :count => 2
  end
end
