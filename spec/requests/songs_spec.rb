require 'rails_helper'
require 'mp3info'

RSpec.describe "/songs", type: :request do

  # This should return the minimal set of attributes required to create a valid
  # Song. As you add validations to Song, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:song)
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      create(:song)
      get songs_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      song = create(:song)
      get song_url(song)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_song_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      song = create(:song)
      get edit_song_url(song)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    before do
      ENV['AWS_REGION'] = 'us-fake-1'
      ENV['AWS_S3_BUCKET'] = 'fake-bucket'
      @file = Tempfile.new(['test_file', '.mp3'])
      allow(Mp3Info).to receive(:new).and_return(double(
        tag: double(title: 'new song', artist: 'artist', year: 2024),
        length: 180
      ))
    end

    after do
      @file.close
      @file.unlink
    end

    let(:uploaded_file) { Rack::Test::UploadedFile.new(@file.path, 'audio/mp3') }
    let(:valid_attributes_with_file) { valid_attributes.merge(file: uploaded_file) }

    context "with valid parameters" do
      context "with existing artist" do
        before do
          @artist = create(:artist, name: 'artist')
          allow_any_instance_of(Aws::S3::Object).to receive(:upload_file)
        end

        it "creates a new Song" do
          expect {
            post songs_url, params: { song: valid_attributes_with_file }
          }.to change(Song, :count).by(1)
        end

        it "redirects to the created song" do
          post songs_url, params: { song: valid_attributes_with_file }
          expect(response).to redirect_to(song_url(Song.last))
        end

        it "uploads the file to s3" do
          expect_any_instance_of(Aws::S3::Object).to receive(:upload_file)
          post songs_url, params: { song: valid_attributes_with_file }
        end

        context "with featured artist" do
          before do
            allow(Mp3Info).to receive(:new).and_return(double(
              tag: double(title: 'new song', artist: 'artist f./Claq', year: 2024),
              length: 180
            ))
          end

          it "uses the correct existing artist" do
            expect {
              post songs_url, params: { song: valid_attributes_with_file }
            }.to change(@artist.songs, :count).by(1)
          end

          it "sets an artist name override" do
            post songs_url, params: { song: valid_attributes_with_file }
            expect(Song.last.artist_name_override).to eq('artist f./Claq')
          end
        end
      end

      context "without existing artist" do
        it "renders new artist template" do
          post songs_url, params: { song: valid_attributes_with_file }
          expect(response.body).to include("New Artist")
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new Song" do
        expect {
          post songs_url, params: { song: invalid_attributes }
        }.to change(Song, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post songs_url, params: { song: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested song" do
        song = create(:song)
        patch song_url(song), params: { song: new_attributes }
        song.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the song" do
        song = create(:song)
        patch song_url(song), params: { song: new_attributes }
        song.reload
        expect(response).to redirect_to(song_url(song))
      end
    end

    context "with invalid parameters" do

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        song = create(:song)
        patch song_url(song), params: { song: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end
end

