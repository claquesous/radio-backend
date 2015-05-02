require 'rails_helper'

RSpec.describe "requests/show", type: :view do
  before(:each) do
    @request = assign(:request, Request.create!(
      :twitter_handle => "Twitter Handle",
      :song => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Twitter Handle/)
    expect(rendered).to match(//)
  end
end
