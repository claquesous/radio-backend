require 'rails_helper'

RSpec.describe "requests/show", type: :view do
  before(:each) do
    @request = assign(:request, create(:request))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/TwitterHandle/)
  end
end
