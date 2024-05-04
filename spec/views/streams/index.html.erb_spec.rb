require 'rails_helper'

RSpec.describe "streams/index", type: :view do
  before(:each) do
    assign(:streams, [
      create(:stream),
      create(:stream),
    ])
  end

  it "renders a list of streams" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("MyStream".to_s), count: 2
  end
end
