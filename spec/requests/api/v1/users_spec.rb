require 'rails_helper'

RSpec.describe 'Users API', type: :request do 
  let!(:user) { create(:user) }
  let(:user_id) { user.id }

  before { host! 'api.taskmanager.test' }

  describe 'GET /users/:id' do 
    before do 
      headers = { 'Accept': 'application/vnd.taskmanager.v1' }
      get "/users/#{user_id}", params: {}, headers: headers
    end 

    context 'when the user exists' do 
      it 'returns the user' do 
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:id]).to eq(user_id)
      end

      it { expect(response).to have_http_status(200) }
    end

    context 'when the user does not exist' do 
      let(:user_id) { 100000 }

      it { expect(response).to have_http_status(404) }
    end
  end

  describe 'POST /users' do 
    before do 
      headers = { 'Accept': 'application/vnd.taskmanager.v1' }
      post '/users', params: { user: user_params }, headers: headers
    end
    context 'when the request params are valid' do 
      let(:user_params) { attributes_for(:user) }

      it { expect(response).to have_http_status(201) } 
      
      it 'returns JSON data for the created user' do 
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq(user_params[:email])
      end
    end

    context 'when the request params are invalid' do 
      let(:user_params) { attributes_for(:user, email: 'invalid-@') }

      it { expect(response).to have_http_status(422) }

      it 'returns the JSON data for the errors' do 
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end
    end
  end

  describe 'PUT /users/:id' do 
    before do 
      headers = { 'Accept': 'application/vnd.taskmanager.v1' }
      put "/users/#{user_id}", params: { user: user_params }, headers: headers
    end
    
    context 'when the request params are valid' do 
      let(:user_params) { { email: 'new@taskmanager.com' } }
      it { expect(response).to have_http_status(200) } 

      it 'returns the JSON data for the updated user' do 
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq(user_params[:email])
      end
    end

    context 'when the request params are invalid' do 
      let(:user_params) { attributes_for(:user, email: 'invalid-@') }
      
      it { expect(response).to have_http_status(422) }

      it 'returns the JSON data for the errors' do 
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end
    end
  end
end