require 'rails_helper'

RSpec.describe "plays/show", type: :view do
  before(:each) do
    @play = assign(:play, Play.create!(
      :song => "",
      :ratings => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/1/)
  end
end
