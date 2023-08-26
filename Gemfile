source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '~> 6.0.3', '>= 6.0.3.5'
gem 'rails', '~> 6.1.7.6'
# Project core gems
# Use postgres as the database for Active Record
gem 'active_model_serializers'
gem 'dry-initializer'
gem 'dry-initializer-rails'
gem 'oj'
# gem 'pg'
gem 'mysql2'
# gem 'pry-rails'
# Use Puma as the app server
# gem 'puma', '~> 5.0' # puma 5.0+ not start as daemon(.... So capistrano not working.
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
# gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'mime-types'
gem 'image_processing', '~> 1.2'
# gem 'whenever', :require => false # have some problems with deploy. maybe in future this gem will be better
gem 'rufus-scheduler'

gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'simple_command'
# gem 'rswag'
gem 'sassc', '~> 2.1.0'
gem 'sass-rails', '>= 6'
gem 'jbuilder', '~> 2.7'
gem 'devise' # required by activeadmin (
gem 'activeadmin'
gem 'bootstrap-sass'
gem 'active_bootstrap_skin'
# gem 'activeadmin_custom_layout'
gem 'api_error_handler'

gem 'rack-cors'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
gem 'rspec-core'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'httparty' # for oauth2 require
gem 'breadcrumbs_on_rails'
gem 'strip_attributes'
gem 'activemerchant'
# gem 'pay', '~> 2.0'
# gem 'stripe', '< 6.0', '>= 2.8'
# gem 'stripe'
# gem 'receipts', '~> 1.0.0'

# gem 'serviceworker-rails'
gem 'webpush'
# gem "serviceworker-rails", github: "rossta/serviceworker-rails", branch: "master"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rspec-rails', '~> 5.0.0'
  # gem 'rswag-specs'
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # gem 'bullet'
end

group :development do
  gem 'letter_opener'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  # gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'capistrano',             require: false
  gem 'capistrano-secrets-yml', require: false
  gem 'capistrano-rbenv',       require: false
  gem 'capistrano-rails',       require: false
  gem 'capistrano-bundler',     require: false
  gem 'capistrano3-puma',       require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 3.26'
  # gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'factory_bot_rails'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false
gem 'geocoder'
gem 'state_machines'
