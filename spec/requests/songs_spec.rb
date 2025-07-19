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

    it "queries by title" do
      create(:song, title: 'abc')
      create(:song, title: 'xyz')

      get songs_url, params: { query: 'abc' }
      expect(response.body).to include('abc')
      expect(response.body).to_not include('xyz')
    end

    it "queries by stream" do
      stream = create(:stream)
      song1 = create(:song, title: 'abc')
      create(:song, title: 'xyz')
      create(:chooser, song: song1, stream: stream)

      get songs_url, params: { stream_id: stream.id }
      expect(response.body).to include('abc')
      expect(response.body).to_not include('xyz')
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      song = create(:song)
      get song_url(song)
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

        it "creates a new Song", :as_logged_in_admin do
          expect {
            post songs_url, params: { song: valid_attributes_with_file }
          }.to change(Song, :count).by(1)
        end

        it "responds with 201", :as_logged_in_admin do
          post songs_url, params: { song: valid_attributes_with_file }
          expect(response).to be_created
        end

        it "uploads the file to s3", :as_logged_in_admin do
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

          it "uses the correct existing artist", :as_logged_in_admin do
            expect {
              post songs_url, params: { song: valid_attributes_with_file }
            }.to change(@artist.songs, :count).by(1)
          end

          it "sets an artist name override", :as_logged_in_admin do
            post songs_url, params: { song: valid_attributes_with_file }
            expect(Song.last.artist_name_override).to eq('artist f./Claq')
          end
        end
      end

      context "without existing artist" do
        it "responds with an error message", :as_logged_in_admin do
          post songs_url, params: { song: valid_attributes_with_file }
          expect(response.body).to include("Artist does not exist")
        end
      end
    end
  end
end

