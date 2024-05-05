require 'rails_helper'

RSpec.describe "ratings/show", type: :view do
  before(:each) do
    @rating = assign(:rating, create(:rating))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/true/)
    expect(rendered).to match(/TwitterHandle/)
  end
end
