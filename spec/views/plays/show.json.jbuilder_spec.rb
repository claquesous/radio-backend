require 'rails_helper'

RSpec.describe "plays/show", type: :view do
  before(:each) do
    @play = assign(:play, create(:play))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
  end
end
