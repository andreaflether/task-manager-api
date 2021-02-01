puts 'Creating User...'
user = User.find_or_create_by!(email: 'user@user.com') do |user|
  user.name = 'User'
  user.password = 'user@123'
  user.password_confirmation = 'user@123'
end

puts 'Creating Tasks...'
20.times do |i|
  Task.create(
    title: Faker::Lorem.sentence,
    description: Faker::Lorem.paragraph,
    done: Faker::Boolean.boolean,
    deadline: rand(1.months).seconds.from_now,
    user: user
  )
end