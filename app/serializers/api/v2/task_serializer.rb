class Api::V2::TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :done, :deadline, :created_at, :updated_at, :user_id,
             :short_description, :is_late, :formatted_deadline

  def short_description 
    object.description.truncate(40) if object.description.present?
  end

  def is_late
    Time.current > object.deadline if object.deadline.present?
  end

  def formatted_deadline
    I18n.l(object.deadline, format: :datetime) if object.deadline.present?
  end

  belongs_to :user
end
             
