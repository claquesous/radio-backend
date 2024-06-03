require 'rails_helper'

RSpec.describe "choosers/show", type: :view do
  before(:each) do
    chooser = assign(:chooser, create(:chooser))
    assign(:stream, chooser.stream)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/true/)
    expect(rendered).to match(/50/)
  end
end
