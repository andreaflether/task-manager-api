require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do 
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

  describe 'GET /tasks' do 
    before do
      create_list(:task, 5, user_id: user.id)
      get '/tasks', params: {}, headers: headers
    end

    context 'when a sorting/search param is sent' do 
      let!(:poi_task_1) { create(:task, title: 'Rewatch POI', user_id: user.id) }
      let!(:root_task_1) { create(:task, title: 'Cry bc Root died', user_id: user.id) }
      let!(:root_task_2) { create(:task, title: 'Tweet about how much i love Root', user_id: user.id) }

      before { get '/tasks', params: { q: { title_cont: 'Root', s: 'ASC' } }, headers: headers }

      it 'returns only the matching tasks' do 
        return_task_titles = json_body[:data].map { |t| t[:attributes][:title] }

        expect(return_task_titles).to eq([root_task_1.title, root_task_2.title])
      end
    end
    
    context 'when no sorting/search param is sent' do 
      it { expect(response).to have_http_status(200) }
      it { expect(json_body[:data].count).to eq(5) }
    end
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