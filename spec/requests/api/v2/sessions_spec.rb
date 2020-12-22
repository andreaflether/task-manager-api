require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do 
  before { host! 'api.task-manager.test' }

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

  describe 'POST /auth/sign_in' do 
    before { post '/auth/sign_in', params: credentials.to_json, headers: headers }

    context 'when the credentials are correct' do
      let(:credentials) { { email: user.email, password: '123456' } }

      it { expect(response).to have_http_status(200) }
      
      it { expect(response.headers).to have_key('access-token') }
      it { expect(response.headers).to have_key('uid') }
      it { expect(response.headers).to have_key('client') }
    end

    context 'when the credentials are incorrect' do
      let(:credentials) { { email: user.email, password: 'abcdef' } }

      it { expect(response).to have_http_status(401) }
      it { expect(json_body).to have_key(:errors) }
    end
  end

  describe 'DELETE /sessions/:id' do
    let(:auth_token) { user.auth_token }

    before { delete "/sessions/#{auth_token}", params: {}, headers: headers }

    it { expect(response).to have_http_status(204) }
    it { expect(User.find_by(auth_token: auth_token)).to be_nil }
  end
end