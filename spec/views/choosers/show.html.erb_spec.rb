require 'rails_helper'

RSpec.describe "choosers/show", type: :view do
  before(:each) do
    assign(:chooser, Chooser.create!(
      song: nil,
      stream: nil,
      featured: false,
      rating: 2.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/2.5/)
  end
end
