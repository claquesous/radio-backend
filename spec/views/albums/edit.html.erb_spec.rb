require 'rails_helper'

RSpec.describe "albums/edit", type: :view do
  before(:each) do
    @album = assign(:album, create(:album))
  end

  it "renders the edit album form" do
    render

    assert_select "form[action=?][method=?]", album_path(@album), "post" do

      assert_select "input#album_artist_id[name=?]", "album[artist_id]"

      assert_select "input#album_title[name=?]", "album[title]"

      assert_select "input#album_sort[name=?]", "album[sort]"

      assert_select "input#album_slug[name=?]", "album[slug]"

      assert_select "input#album_tracks[name=?]", "album[tracks]"

      assert_select "input#album_id3_genre[name=?]", "album[id3_genre]"

      assert_select "input#album_record_label[name=?]", "album[record_label]"
    end
  end
end
