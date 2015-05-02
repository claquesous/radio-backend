require 'rails_helper'

RSpec.describe "requests/edit", type: :view do
  before(:each) do
    @request = assign(:request, Request.create!(
      :twitter_handle => "MyString",
      :song => ""
    ))
  end

  it "renders the edit request form" do
    render

    assert_select "form[action=?][method=?]", request_path(@request), "post" do

      assert_select "input#request_twitter_handle[name=?]", "request[twitter_handle]"

      assert_select "input#request_song[name=?]", "request[song]"
    end
  end
end
