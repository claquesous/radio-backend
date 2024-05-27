require 'rails_helper'

RSpec.describe "choosers/index", type: :view do
  before(:each) do
    assign(:choosers, [
      Chooser.create!(
        song: nil,
        stream: nil,
        featured: false,
        rating: 2.5
      ),
      Chooser.create!(
        song: nil,
        stream: nil,
        featured: false,
        rating: 2.5
      )
    ])
  end

  it "renders a list of choosers" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.5.to_s), count: 2
  end
end
