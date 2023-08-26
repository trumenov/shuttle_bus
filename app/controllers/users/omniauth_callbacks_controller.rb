# frozen_string_literal: true
require 'httparty'
require 'json'
# require 'open-uri'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # before_action :tmp_dbg_proc123123
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # def initialize
  #   puts "\n\n\n\n Devise::OmniauthCallbacksController initialize \n\n\n\n"
  #   super
  # end

  # def tmp_dbg_proc123123
  #   request.params['redirect_uri'] = Rails.application.secrets[:swager_host] + '/profile/auth/google_oauth2/callback'
  #   puts "\n\n\n statred tmp_dbg_proc123123 params=[#{ params.inspect }] \n\n\n "
  #   # puts "\n\n\n statred tmp_dbg_proc123123 params=[#{ params.inspect }] \n\n\n request.env=[#{ request.env.inspect }] \n\n\n\n\n\n\n\n\n\n\n\n"
  # end


  # GET|POST /users/auth/twitter/callback
  # def failure
    # puts "\n\n\n statred failure code=[#{ request.params["code"] }] params=[#{ params.inspect }] \n\n\n request.env=[#{ request.env.inspect }] \n\n\n"
    # raise("TMP STOP failure 213132231132.")
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  def facebook
    user = User.create_user_for_facebook(request.env['omniauth.auth'], request.remote_ip)
    if user.persisted? && user.save
      # img_src = "http://graph.facebook.com/#{self.uid}/picture?type=large"
      # img_src = request.env['omniauth.auth'].info['image']
      # if img_src && img_src.size_positive? && (!(user.avatar.attached?))
      #   puts "\n\n\n\n facebook img_src=[#{ img_src }] \n\n\n"
      #   new_avatar = URI.open(img_src)
      #   puts "\n\n\n\n facebook new_avatar=[#{ new_avatar.inspect }] \n\n\n"
      # end
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Facebook'
      return sign_in_and_redirect user, event: :authentication
    end
    # puts "\n\n\n user=[#{ user.errors.inspect }] \n\n\n"
    # Removing extra as it can overflow some session stores
    redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
  end

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    # puts "\n\n\n statred google_oauth2  \n\n\n request.env['omniauth.auth']=[#{ request.env['omniauth.auth'].inspect }] \n\n\n"

    # @user = User.from_omniauth(request.env['omniauth.auth'])

    # url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{ params["id_token"] }"
    # puts "\n\n\n statred google_oauth2 url=[#{ url }] \n\n\n params=[#{ params.inspect }] \n\n\n"
    # response = HTTParty.get(url)
    # user = User.create_user_for_google(response.parsed_response)
    # tokens = @user.create_new_auth_token
    user = User.create_user_for_google(request.env['omniauth.auth'], request.remote_ip)

    if user.persisted? && user.save
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      # puts "\n\n\n user=[#{ user.errors.inspect }] \n\n\n"
      # Removing extra as it can overflow some session stores
      # session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
    end
  end
end
