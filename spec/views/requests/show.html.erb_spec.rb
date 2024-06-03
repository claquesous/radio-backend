require 'rails_helper'

RSpec.describe "requests/show", type: :view do
  before(:each) do
    @request = assign(:request, create(:request))
    assign(:stream, @request.stream)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/false/)
  end
end
