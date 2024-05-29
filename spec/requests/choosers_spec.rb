require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/choosers", type: :request do
  
  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      chooser = create(:chooser)
      get stream_choosers_url(chooser.stream)
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      chooser = create(:chooser)
      get stream_chooser_url(chooser.stream, chooser)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      chooser = create(:chooser)
      get edit_stream_chooser_url(chooser.stream, chooser)
      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested chooser" do
        chooser = create(:chooser)
        patch stream_chooser_url(chooser.stream, chooser), params: { chooser: new_attributes }
        chooser.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the chooser" do
        chooser = create(:chooser)
        patch stream_chooser_url(chooser.stream, chooser), params: { chooser: new_attributes }
        chooser.reload
        expect(response).to redirect_to(stream_chooser_url(chooser.stream, chooser))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        chooser = create(:chooser)
        patch stream_chooser_url(chooser.stream, chooser), params: { chooser: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

end
