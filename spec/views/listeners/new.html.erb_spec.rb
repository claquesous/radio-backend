require 'rails_helper'

RSpec.describe "listeners/new", type: :view do
  before(:each) do
    assign(:listener, Listener.new(
      :twitter_handle => "MyString"
    ))
  end

  it "renders new listener form" do
    render

    assert_select "form[action=?][method=?]", listeners_path, "post" do

      assert_select "input#listener_twitter_handle[name=?]", "listener[twitter_handle]"
    end
  end
end
