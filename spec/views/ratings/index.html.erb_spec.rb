require 'rails_helper'

RSpec.describe "ratings/index", type: :view do
  before(:each) do
    assign(:ratings, [
      Rating.create!(
        :play => "",
        :up => false,
        :twitter_handle => "Twitter Handle"
      ),
      Rating.create!(
        :play => "",
        :up => false,
        :twitter_handle => "Twitter Handle"
      )
    ])
  end

  it "renders a list of ratings" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Twitter Handle".to_s, :count => 2
  end
end
