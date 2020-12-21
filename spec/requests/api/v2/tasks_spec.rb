require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do 
  before { host! 'api.task-manager.test' }

  let!(:user) { create(:user) }
  let(:headers) do
    {
      'Accept': 'application/vnd.taskmanager.v2',
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
    it { expect(json_body[:data].count).to eq(5) }
  end
 
  describe 'GET /tasks/:id' do 
    let(:task) { create(:task, user_id: user.id) }

    before { get "/tasks/#{task.id}", params: {}, headers: headers }
    
    it { expect(response).to have_http_status(200) }
    it { expect(json_body[:data][:attributes][:title]).to eq(task.title)}
  end

  describe 'POST /tasks' do 
    before { post '/tasks', params: { task: task_params }.to_json, headers: headers } 
  
    context 'when the params are valid' do
      let(:task_params) { attributes_for(:task) }

      it { expect(response).to have_http_status(201) }  
      it { expect(Task.find_by(title: task_params[:title])).not_to be_nil }
      it { expect(json_body[:data][:attributes][:title]).to eq(task_params[:title]) }
      it { expect(json_body[:data][:attributes][:'user-id']).to eq(user.id) }
    end

    context 'when the params are invalid' do
      let(:task_params) { attributes_for(:task, title: '') }

      it { expect(response).to have_http_status(422) }
      it { expect(Task.find_by(title: task_params[:title])).to be_nil }
      it { expect(json_body[:errors]).to have_key(:title) }
    end
  end

  describe 'PUT /tasks/:id' do 
    let!(:task) { create(:task, user_id: user.id) }
    
    before { put "/tasks/#{task.id}", params: { task: task_params }.to_json, headers: headers }

    context 'when the params are valid' do 
      let(:task_params) { { title: 'New task title' } }

      it { expect(response).to have_http_status(200) }
      it { expect(json_body[:data][:attributes][:title]).to eq(task_params[:title])}
      it { expect(Task.find_by(title: task_params[:title])).not_to be_nil }
    end

    context 'when the params are invalid' do 
      let(:task_params) { { title: '' } }

      it { expect(response).to have_http_status(422) }
      it { expect(json_body[:errors]).to have_key(:title) }
      it { expect(Task.find_by(title: task_params[:title])).to be_nil }
    end
  end

  describe 'DELETE /tasks/:id' do 
    let!(:task) { create(:task, user_id: user.id) }

    before { delete "/tasks/#{task.id}", params: {}, headers: headers }

    it { expect(response).to have_http_status(204) }
    it { expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end