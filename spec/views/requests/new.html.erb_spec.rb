require 'rails_helper'

RSpec.describe "requests/new", type: :view do
  before(:each) do
    assign(:request, Request.new(
      :twitter_handle => "MyString",
      :song => ""
    ))
  end

  it "renders new request form" do
    render

    assert_select "form[action=?][method=?]", requests_path, "post" do

      assert_select "input#request_twitter_handle[name=?]", "request[twitter_handle]"

      assert_select "input#request_song[name=?]", "request[song]"
    end
  end
end
