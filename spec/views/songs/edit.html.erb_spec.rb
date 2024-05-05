require 'rails_helper'

RSpec.describe "songs/edit", type: :view do
  before(:each) do
    @song = assign(:song, create(:song))
  end

  it "renders the edit song form" do
    render

    assert_select "form[action=?][method=?]", song_path(@song), "post" do

      assert_select "input#song_album_id[name=?]", "song[album_id]"

      assert_select "input#song_artist_id[name=?]", "song[artist_id]"

      assert_select "input#song_title[name=?]", "song[title]"

      assert_select "input#song_sort[name=?]", "song[sort]"

      assert_select "input#song_slug[name=?]", "song[slug]"

      assert_select "input#song_track[name=?]", "song[track]"

      assert_select "input#song_time[name=?]", "song[time]"

      assert_select "input#song_featured[name=?]", "song[featured]"

      assert_select "input#song_live[name=?]", "song[live]"

      assert_select "input#song_remix[name=?]", "song[remix]"

      assert_select "input#song_rating[name=?]", "song[rating]"
    end
  end
end
