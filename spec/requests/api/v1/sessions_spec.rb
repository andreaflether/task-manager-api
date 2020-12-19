require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do 
  before { host! 'api.task-manager.test' }
  let(:user) { create(:user) }
  let(:headers) do 
    {
      'Accept': 'application/vnd.taskmanager.v1',
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
        # user.reload 
        expect(json_body[:auth_token]).to eq(user.auth_token)
      end
    end

    context 'when the credentials are incorrect' do
      let(:credentials) { { email: user.email, password: 'abcdef' } }

      it { expect(response).to have_http_status(401) }
      it { expect(json_body).to have_key(:errors) }
    end
  end
end