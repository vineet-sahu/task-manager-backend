class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :email, :created_at, :updated_at

  attribute :full_name do |user|
    "#{user.first_name} #{user.last_name}"
  end

  attribute :formatted_created_at do |user|
    user.created_at.strftime('%B %d, %Y')
  end
end
