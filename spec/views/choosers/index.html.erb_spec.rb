require 'rails_helper'

RSpec.describe "choosers/index", type: :view do
  before(:each) do
    assign(:stream, create(:stream))
    assign(:choosers, [
      create(:chooser),
      create(:chooser)
    ])
  end

  it "renders a list of choosers" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new(true.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(50.to_s), count: 2
  end
end
