source 'https://www.rubygems.org'

gem 'sinatra'
gem 'tilt', '~> 1.4.1'
gem 'tilt-jbuilder', require: 'sinatra/jbuilder'

gem 'httparty'

gem 'endpoint_base', github: 'spree/endpoint_base'
gem 'capistrano'
gem 'honeybadger'

group :development, :test do
  gem 'pry'
  gem 'shotgun'
end

group :test do
  gem 'vcr'
  gem 'rspec'
  gem 'rack-test'
  gem 'webmock'
end

group :production do
  gem 'foreman'
  gem 'unicorn'
end
