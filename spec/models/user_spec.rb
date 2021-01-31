require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
  
  it { is_expected.to have_many(:tasks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive.scoped_to(:provider) }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value('andrea@mail.com').for(:email) }
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do 
    it 'returns the email, created_at and a token' do 
      user.save!
      allow(Devise).to receive(:friendly_token).and_return('Pt%54V@g3cr&F0r#3')
      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: #{Devise.friendly_token}")
    end
  end

  describe '#generate_authentication_token!' do
    it 'generates a unique auth token' do 
      allow(Devise).to receive(:friendly_token).and_return('Pt%54V@g3cr&F0r#3')
      user.generate_authentication_token!

      expect(user.auth_token).to eq('Pt%54V@g3cr&F0r#3')
    end

    it 'generates another auth token when the current auth token already has been taken' do
      allow(Devise).to receive(:friendly_token).and_return('4d1ff3r3#tT0*3#', '4d1ff3r3#tT0*3#', '4#0th3r0#3')  
      existing_user = create(:user)
      user.generate_authentication_token!

      expect(user.auth_token).not_to eq(existing_user.auth_token)
    end
  end
end
