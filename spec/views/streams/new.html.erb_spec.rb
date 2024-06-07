require 'rails_helper'

RSpec.describe "streams/new", type: :view do
  before(:each) do
    assign(:stream, Stream.new(
      name: "MyString",
      user_id: 1
    ))
  end

  it "renders new stream form" do
    render

    assert_select "form[action=?][method=?]", streams_path, "post" do

      assert_select "input[name=?]", "stream[name]"

      assert_select "input[name=?]", "stream[default_rating]"

      assert_select "input[name=?]", "stream[default_featured]"

      assert_select "input[name=?]", "stream[mastodon_url]"

      assert_select "input[name=?]", "stream[mastodon_access_token]"
    end
  end
end
