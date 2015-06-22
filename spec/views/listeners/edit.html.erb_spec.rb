require 'rails_helper'

RSpec.describe "listeners/edit", type: :view do
  before(:each) do
    @listener = assign(:listener, Listener.create!(
      :twitter_handle => "MyString"
    ))
  end

  it "renders the edit listener form" do
    render

    assert_select "form[action=?][method=?]", listener_path(@listener), "post" do

      assert_select "input#listener_twitter_handle[name=?]", "listener[twitter_handle]"
    end
  end
end
