class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks, dependent: :destroy

  validates :auth_token, uniqueness: true
  before_create :generate_auth_token!

  def info 
    "#{email} - #{created_at} - Token: #{Devise.friendly_token}"
  end

  def generate_auth_token!
    begin
      self.auth_token = Devise.friendly_token      
    end while User.exists?(auth_token: auth_token)
  end
end
