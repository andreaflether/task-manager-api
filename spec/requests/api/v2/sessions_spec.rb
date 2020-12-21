require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do 
  before { host! 'api.task-manager.test' }
  let(:user) { create(:user) }
  let(:headers) do 
    {
      'Accept': 'application/vnd.taskmanager.v2',
      'Content-Type': Mime[:json].to_s
    }
  end

  describe 'POST /sessions' do 
    before do 
      post '/sessions', params: { session: credentials }.to_json, headers: headers
    end

    context 'when the credentials are correct' do
      let(:credentials) { { email: user.email, password: '123456' } }

      it { expect(response).to have_http_status(200) }
      
      it 'returns the JSON data for the user with auth token' do 
        user.reload 
        expect(json_body[:data][:attributes][:'auth-token']).to eq(user.auth_token)
      end
    end

    context 'when the credentials are incorrect' do
      let(:credentials) { { email: user.email, password: 'abcdef' } }

      it { expect(response).to have_http_status(401) }
      it { expect(json_body).to have_key(:errors) }
    end
  end

  describe 'DELETE /sessions/:id' do
    let(:auth_token) { user.auth_token }

    before do 
      delete "/sessions/#{auth_token}", params: {}, headers: headers
    end

    it { expect(response).to have_http_status(204) }
    it { expect(User.find_by(auth_token: auth_token)).to be_nil }
  end
end