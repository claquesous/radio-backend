require 'rails_helper'

RSpec.describe "ratings/show", type: :view do
  before(:each) do
    @rating = assign(:rating, Rating.create!(
      :play => "",
      :up => false,
      :twitter_handle => "Twitter Handle"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Twitter Handle/)
  end
end
