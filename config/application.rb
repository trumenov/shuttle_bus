require_relative "boot"

# require "ext/string"
# require "rails/all"
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
# require 'active_job/railtie'
require 'action_cable/engine'
# require 'action_mailbox/engine'
# require 'action_text/engine'
# require 'rails/test_unit/railtie'
# require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShuttleBus
  class Application < Rails::Application
    config.action_dispatch.cookies_same_site_protection = :lax
    if Rails.env.development?
      # config.web_console.whitelisted_ips = ['192.168.0.0/16','10.8.0.0/24', '91.196.80.0/22', '3.87.91.0/24']
    end
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 6.1
    config.load_defaults 6.0

    config.action_mailer.default :charset => "utf-8"
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'example.com',
      user_name:            Rails.application.secrets[:gmail_user_name],
      password:             Rails.application.secrets[:gmail_user_pass],
      authentication:       'plain',
      enable_starttls_auto: true
    }

    # raise("TMP STOP 312312123. s=[#{ Rails.application.secrets }]")


    config.autoload_paths << Rails.root.join('lib')
    # config.autoload_paths << Rails.root.join('app/helpers')
    config.autoload_paths << Rails.root.join('app/validators')

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.to_prepare do
      Devise::SessionsController.layout "pages_main.html"
      Devise::RegistrationsController.layout "pages_main.html"
      Devise::ConfirmationsController.layout "pages_main.html"
      Devise::UnlocksController.layout "pages_main.html"
      Devise::PasswordsController.layout "pages_main.html"
    end

    config.generators do |g|
      g.orm :active_record, { primary_key_type: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" }
    end
  end
end
