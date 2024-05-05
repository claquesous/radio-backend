require 'rails_helper'

RSpec.describe "songs/show", type: :view do
  before(:each) do
    @song = assign(:song, create(:song))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
  end
end
