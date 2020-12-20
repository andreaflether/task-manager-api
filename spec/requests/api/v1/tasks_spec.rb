require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do 
  before { host! 'api.task-manager.test' }

  let!(:user) { create(:user) }
  let(:headers) do
    {
      'Accept': 'application/vnd.taskmanager.v1',
      'Content-Type': Mime[:json].to_s,
      'Authorization': user.auth_token
    }
  end

  describe 'GET /tasks' do 
    before do 
      create_list(:task, 5, user_id: user.id)
      get '/tasks', params: {}, headers: headers
    end

    it { expect(response).to have_http_status(200) }
    it { expect(json_body[:tasks].count).to eq(5) }
  end

  describe 'GET /tasks/:id' do 
    let(:task) { create(:task, user_id: user.id) }

    before { get "/tasks/#{task.id}", params: {}, headers: headers }
    
    it { expect(response).to have_http_status(200) }
    it { expect(json_body[:title]).to eq(task.title)}
  end

  describe 'POST /tasks' do 
    before do 
      post '/tasks', params: { task: task_params }.to_json, headers: headers
    end

    context 'when the params are valid' do
      let(:task_params) { attributes_for(:task) }

      it { expect(response).to have_http_status(201) }  
      it { expect(Task.find_by(title: task_params[:title])).not_to be_nil }
      it { expect(json_body[:title]).to eq(task_params[:title]) }
      it { expect(json_body[:user_id]).to eq(user.id) }
    end

    context 'when the params are invalid' do
      let(:task_params) { attributes_for(:task, title: '') }

      it { expect(response).to have_http_status(422) }
      it { expect(Task.find_by(title: task_params[:title])).to be_nil }
      it { expect(json_body[:errors]).to have_key(:title) }
    end
  end
end
