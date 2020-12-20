require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:task) { build(:task) }

  context 'when is new' do 
    it { expect(task).not_to be_done }
  end

  it { should belong_to(:user) }

  it { is_expected.to validate_presence_of :title }
  # it { is_expected.to validate_presence_of :user_id }
  it { is_expected.not_to allow_value(nil).for(:user) }
  
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:deadline) }
  it { is_expected.to respond_to(:done) }
  it { is_expected.to respond_to(:user_id) }
end
