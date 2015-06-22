require 'rails_helper'

RSpec.describe "listeners/show", type: :view do
  before(:each) do
    @listener = assign(:listener, Listener.create!(
      :twitter_handle => "Twitter Handle"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Twitter Handle/)
  end
end
