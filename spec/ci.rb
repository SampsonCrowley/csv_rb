#!/usr/bin/env ruby

puts "Testing Rails 5"
exit system('cd spec/dummy && bundle install --without debug && bundle exec rake db:create && bundle exec rake db:migrate && cd ../../ && bundle exec rspec spec')
