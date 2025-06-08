require 'rails_helper'

RSpec.describe "streams/show", type: :view do
  before(:each) do
    assign(:stream, create(:stream))
  end

  it "renders attributes in <p>" do
    render
    puts rendered
    expect(rendered).to match(/MyStream/)
  end
end
