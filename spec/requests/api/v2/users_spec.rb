require 'rails_helper'

RSpec.describe 'Users API', type: :request do 
  let!(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:headers) do
    {
      'Accept': 'application/vnd.taskmanager.v2',
      'Content-Type': Mime[:json].to_s,
      'Authorization': user.auth_token
    }
  end

  before { host! 'api.task-manager.test' }

  describe 'GET /users/:id' do 
    before do 
      get "/users/#{user_id}", params: {}, headers: headers
    end 

    context 'when the user exists' do 
      it { expect(json_body[:data][:id].to_i).to eq(user_id) }
      it { expect(response).to have_http_status(200) }
    end

    context 'when the user does not exist' do 
      let(:user_id) { 100000 }

      it { expect(response).to have_http_status(404) }
    end
  end

  describe 'POST /users' do 
    before do 
      post '/users', params: { user: user_params }.to_json, headers: headers
    end
    context 'when the request params are valid' do 
      let(:user_params) { attributes_for(:user) }

      it { expect(response).to have_http_status(201) }  
      it { expect(json_body[:data][:attributes][:email]).to eq(user_params[:email]) }
    end

    context 'when the request params are invalid' do 
      let(:user_params) { attributes_for(:user, email: 'invalid-@') }

      it { expect(response).to have_http_status(422) }
      it { expect(json_body).to have_key(:errors) }
    end
  end

  describe 'PUT /users/:id' do 
    before do 
      put "/users/#{user_id}", params: { user: user_params }.to_json, headers: headers
    end
    
    context 'when the request params are valid' do 
      let(:user_params) { { email: 'new@taskmanager.com' } }
      it { expect(response).to have_http_status(200) } 
      it { expect(json_body[:data][:attributes][:email]).to eq(user_params[:email]) }
    end

    context 'when the request params are invalid' do 
      let(:user_params) { attributes_for(:user, email: 'invalid-@') }

      it { expect(response).to have_http_status(422) }
      it { expect(json_body).to have_key(:errors) }
    end
  end

  describe 'DELETE /users/:id' do 
    before do 
      delete "/users/#{user_id}", params: { }, headers: headers
    end

    it { expect(response).to have_http_status(204) }
    it { expect(User.find_by(id: user.id)).to be_nil }     
  end
end