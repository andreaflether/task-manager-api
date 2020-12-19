class Api::V1::SessionsController < ApplicationController
  def create 
    user = User.find_by(email: session_params[:email])

    if user && user.valid_password?(session_params[:password])
      render json: user, status: 200
      user.generate_auth_token!
      user.save
      sign_in user, store: false
    else
      render json: { errors: user.errors }, status: 401
    end
  end

  def destroy 
    user = User.find_by(auth_token: params[:id])
    user.generate_auth_token!
    user.save
    head 204
  end

  private
  
  def session_params 
    params.require(:session).permit(:email, :password)
  end
end
