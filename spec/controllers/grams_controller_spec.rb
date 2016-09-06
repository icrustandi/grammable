require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy" do
    it "should allow user to destroy gram" do
      dgram = FactoryGirl.create(:gram)
      delete :destroy, id: dgram.id

      expect(response).to redirect_to root_path
      dgram = Gram.find_by_id(dgram.id)
      expect(dgram).to eq nil
    end

    it "should render 404 if gram cannot be found" do
      delete :destroy, id: 'HARAMBE'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update" do
    it "should allow user to update gram" do
      ugram = FactoryGirl.create(:gram, message: "Initial value")
      patch :update, id: ugram.id, gram: {message: "changed value"}

      expect(response).to redirect_to root_path

      ugram.reload
      expect(ugram.message).to eq "changed value"
    end

    it "should render 404 if gram cannot be found" do
      patch :update, id: "HARAMBE", gram: {message: 'changed value'}
      expect(response).to have_http_status(:not_found)
    end

    it "should render edit form with unprocessable_entity" do
      ugram = FactoryGirl.create(:gram, message: "Initial value")
      patch :update, id: ugram.id, gram: {message: ""}

      expect(response).to have_http_status(:unprocessable_entity)

      ugram.reload
      expect(ugram.message).to eq "Initial value"
    end
  end


  describe "grams#edit" do
    it "should show edit form if gram is found" do
      egram = FactoryGirl.create(:gram)
      get :edit, id: egram.id
      expect(response).to have_http_status(:success)
    end

    it "should return 404 if gram is not found"do
      get :edit, id: 'HARAMBE'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram) 
      get :show, id: gram.id

      expect(response).to have_http_status(:success)
    end
    
    it "should return a 404 error if the gram is not found" do
      get :show, id: 'HARAMBE'
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require user to log in" do
      post :create, gram: { message: "Hello" }
      expect(response).to redirect_to new_user_session_path
    end

    it "should show new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do
      post :create, gram: { message: "Hello" }
      expect(response).to redirect_to new_user_session_path
    end
    
    it "should create a new gram in database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {message: 'Test Gram!'}
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Test Gram!")
      expect(gram.user).to eq(user)
    end

    it "should deal with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
    end
  end

end