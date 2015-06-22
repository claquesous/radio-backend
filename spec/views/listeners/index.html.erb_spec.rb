require 'rails_helper'

RSpec.describe "listeners/index", type: :view do
  before(:each) do
    assign(:listeners, [
      Listener.create!(
        :twitter_handle => "Twitter Handle"
      ),
      Listener.create!(
        :twitter_handle => "Twitter Handle"
      )
    ])
  end

  it "renders a list of listeners" do
    render
    assert_select "tr>td", :text => "Twitter Handle".to_s, :count => 2
  end
end
