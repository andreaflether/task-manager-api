class Api::V1::TasksController < ApplicationController
  before_action :authenticate_with_token!, only: [:index]
  
  def index 
    tasks = current_user.tasks
    render json: { tasks: tasks }, status: 200
  end
end
