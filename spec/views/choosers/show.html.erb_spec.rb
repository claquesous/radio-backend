require 'rails_helper'

RSpec.describe "choosers/show", type: :view do
  before(:each) do
    assign(:chooser, create(:chooser))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/true/)
    expect(rendered).to match(/50/)
  end
end
