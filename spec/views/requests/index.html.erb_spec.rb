require 'rails_helper'

RSpec.describe "requests/index", type: :view do
  before(:each) do
    stream = create(:stream)
    assign(:stream, stream)
    assign(:requests, [
      create(:request),
      create(:request),
    ])
  end

  it "renders a list of requests" do
    render
    assert_select "tr>td:nth-child(3)", :text => "false", :count => 2
  end
end
