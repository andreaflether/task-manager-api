require 'rails_helper'

RSpec.describe 'Users API', type: :request do 
  let!(:user) { create(:user) }
  let(:auth_data) { user.create_new_auth_token }
  let(:headers) do
    {
      'Accept': 'application/vnd.taskmanager.v2',
      'Content-Type': Mime[:json].to_s,
      'access-token': auth_data['access-token'],
      'uid': auth_data['uid'],
      'client': auth_data['client']
    }
  end

  before { host! 'api.task-manager.test' }

  describe 'GET /auth/validate_token' do    
    context 'when the request headers are valid' do 
      before do 
        get '/auth/validate_token', params: {}, headers: headers
      end

      it { expect(json_body[:data][:id].to_i).to eq(user.id) }
      it { expect(response).to have_http_status(200) }
    end

    context 'when the request headers are not valid' do 
      before do
        headers['access-token'] = 'invalid-token' 
        get '/auth/validate_token', params: {}, headers: headers
      end

      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'POST /auth' do 
    before do 
      post '/auth', params: user_params.to_json, headers: headers
    end
    context 'when the request params are valid' do 
      let(:user_params) { attributes_for(:user) }

      it { expect(response).to have_http_status(200) }  
      it { expect(json_body[:data][:email]).to eq(user_params[:email]) }
    end

    context 'when the request params are invalid' do 
      let(:user_params) { attributes_for(:user, email: 'invalid-@') }

      it { expect(response).to have_http_status(422) }
      it { expect(json_body).to have_key(:errors) }
    end
  end

  describe 'PUT /auth' do 
    before do 
      put '/auth', params: user_params.to_json, headers: headers
    end
    
    context 'when the request params are valid' do 
      let(:user_params) { { email: 'new@taskmanager.com' } }
      it { expect(response).to have_http_status(200) } 
      it { expect(json_body[:data][:email]).to eq(user_params[:email]) }
    end

    context 'when the request params are invalid' do 
      let(:user_params) { attributes_for(:user, email: 'invalid-@') }

      it { expect(response).to have_http_status(422) }
      it { expect(json_body).to have_key(:errors) }
    end
  end

  describe 'DELETE /auth' do 
    before do 
      delete '/auth', params: { }, headers: headers
    end

    it { expect(response).to have_http_status(200) }
    it { expect(User.find_by(id: user.id)).to be_nil }     
  end
end