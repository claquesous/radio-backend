require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ArtistsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Artist. As you add validations to Artist, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ArtistsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all artists as @artists" do
      artist = Artist.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:artists)).to eq([artist])
    end
  end

  describe "GET #show" do
    it "assigns the requested artist as @artist" do
      artist = Artist.create! valid_attributes
      get :show, {:id => artist.to_param}, valid_session
      expect(assigns(:artist)).to eq(artist)
    end
  end

  describe "GET #edit" do
    it "assigns the requested artist as @artist" do
      artist = Artist.create! valid_attributes
      get :edit, {:id => artist.to_param}, valid_session
      expect(assigns(:artist)).to eq(artist)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Artist" do
        expect {
          post :create, {:artist => valid_attributes}, valid_session
        }.to change(Artist, :count).by(1)
      end

      it "assigns a newly created artist as @artist" do
        post :create, {:artist => valid_attributes}, valid_session
        expect(assigns(:artist)).to be_a(Artist)
        expect(assigns(:artist)).to be_persisted
      end

      it "redirects to the created artist" do
        post :create, {:artist => valid_attributes}, valid_session
        expect(response).to redirect_to(Artist.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved artist as @artist" do
        post :create, {:artist => invalid_attributes}, valid_session
        expect(assigns(:artist)).to be_a_new(Artist)
      end

      it "re-renders the 'new' template" do
        post :create, {:artist => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested artist" do
        artist = Artist.create! valid_attributes
        put :update, {:id => artist.to_param, :artist => new_attributes}, valid_session
        artist.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested artist as @artist" do
        artist = Artist.create! valid_attributes
        put :update, {:id => artist.to_param, :artist => valid_attributes}, valid_session
        expect(assigns(:artist)).to eq(artist)
      end

      it "redirects to the artist" do
        artist = Artist.create! valid_attributes
        put :update, {:id => artist.to_param, :artist => valid_attributes}, valid_session
        expect(response).to redirect_to(artist)
      end
    end

    context "with invalid params" do
      it "assigns the artist as @artist" do
        artist = Artist.create! valid_attributes
        put :update, {:id => artist.to_param, :artist => invalid_attributes}, valid_session
        expect(assigns(:artist)).to eq(artist)
      end

      it "re-renders the 'edit' template" do
        artist = Artist.create! valid_attributes
        put :update, {:id => artist.to_param, :artist => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested artist" do
      artist = Artist.create! valid_attributes
      expect {
        delete :destroy, {:id => artist.to_param}, valid_session
      }.to change(Artist, :count).by(-1)
    end

    it "redirects to the artists list" do
      artist = Artist.create! valid_attributes
      delete :destroy, {:id => artist.to_param}, valid_session
      expect(response).to redirect_to(artists_url)
    end
  end

end
