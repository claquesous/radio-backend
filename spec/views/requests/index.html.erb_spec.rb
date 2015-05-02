require 'rails_helper'

RSpec.describe "requests/index", type: :view do
  before(:each) do
    assign(:requests, [
      Request.create!(
        :twitter_handle => "Twitter Handle",
        :song => ""
      ),
      Request.create!(
        :twitter_handle => "Twitter Handle",
        :song => ""
      )
    ])
  end

  it "renders a list of requests" do
    render
    assert_select "tr>td", :text => "Twitter Handle".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
