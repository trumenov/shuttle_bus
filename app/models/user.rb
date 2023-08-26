# frozen_string_literal: true
# require 'mini_magick'
# include Rails.application.routes.url_helpers

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable, :lockable, :timeoutable, :confirmable, :recoverable, :rememberable,
    :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  # has_secure_password
  # has_one :profile, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :user_stations, dependent: :destroy
  has_many :user_routes, dependent: :destroy
  has_many :trips, through: :user_routes
  has_many :trip_chat_msg_unreads, dependent: :destroy
  has_many :user_push_subscriptions, dependent: :destroy
  has_many :user_notifications, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :trip_ticket_pack, through: :tickets
  has_many :ticketed_trips, through: :trip_ticket_pack, source: :trip



  # has_one :user_serializer
  has_one_attached :avatar

  # attr_accessor :skip_set_dimensions
  # after_commit ({unless: :skip_set_dimensions}) { |image| set_dimensions image }

  validates :password, presence: true, length: { in: 6..50 }, allow_blank: true
  validates :email, uniqueness: { case_sensitive: true }, format: { with: /\A[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\z/ }, presence: true, length: { in: 5..100 }
  validate :acceptable_avatar
  validate :validate_age

  scope :active, -> { where(deleted_at: nil) }

  # def gen_auth_token
  #   id.positive? ? ::JsonWebToken.encode(user_id: id) : nil
  # end

  # def avatar_urls
  #   ::Users::GetAvatarUrls.call(avatar) if avatar.attached?
  # end

  def sm_avatar_url
    avatar.attached? ? Rails.application.routes.url_helpers.url_for(avatar_thumb) : self.class.no_profile_avatar_sm_url
  end
  # def user_born_time_unixtime; user_born_time.nil? ? nil : user_born_time.to_time.to_i; end
  # def created_at_unixtime; created_at.nil? ? nil : created_at.to_time.to_i; end
  def password_changed_at_unixtime; password_changed_at.nil? ? nil : password_changed_at.to_time.to_i; end
  def user_max_subscriptions_cnt; 10000; end
  def user_max_events_cnt; 100; end
  def event_max_images_cnt; 20; end
  def name!; name || 'NoUserName'; end
  def name_or_email_for_public
    print_name = 'NoUserName'
    if name.to_s.size_positive?
      print_name = name
    else
      if email.to_s.size > 10
        print_name = "#{ email[0..2] }***#{ email[(email.size - 3)..-1] }"
      end
    end
    print_name
  end

  def acceptable_avatar
    return unless avatar.attached?
    unless avatar.byte_size <= 4.megabyte
      errors.add(:avatar, "is too big")
    end

    acceptable_types = ["image/jpeg", "image/png"]
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "must be a JPEG or PNG")
    end
  end

  def self.create_user_for_facebook(access_token, ip)
    data = access_token.info
    # puts "\n\n\n\n\n create_user_for_facebook data=[#{ data.to_json }] \n\n\n\n"
    name_split = data['name'].split(" ")
    name_split = [""] + name_split unless (name_split.count > 1)
    user = User.where(email: data['email']).first
    # raise("TMP STOP 12313221. user=[#{ user.to_json }]")
    if user
      user.update_attribute(:confirmed_at, Time.current) unless user.confirmed?
    else
      user = User.create(name: name_split[1], last_name: name_split[0], email: data['email'], confirmed_at: Time.current,
                         password: Devise.friendly_token[0,20],
                         current_sign_in_ip: ip, last_sign_in_ip: ip,
                         current_password_unknown: 1)
      user.password_confirmation = user.password
    end
    user
  end

  def self.create_user_for_google(access_token, ip)
    data = access_token.info
    # puts "\n\n\n\n\n create_user_for_google data=[#{ data.to_json }] \n\n\n\n"
    user = User.where(email: data['email']).first
    if user
      user.update_attribute(:confirmed_at, Time.current) unless user.confirmed?
    else
      user = User.create(name: data['name'], email: data['email'], confirmed_at: Time.current,
                         password: Devise.friendly_token[0,20],
                         current_sign_in_ip: ip, last_sign_in_ip: ip,
                         current_password_unknown: 1)
      user.password_confirmation = user.password
    end
    user
  end

  def webpush_subscriptions_auths; user_push_subscriptions.map(&:webpush_key_auth); end

  # def password_digest(password)
  #   Devise::Encryptor.digest(self.class, password)
  # end

  def validate_age
    # if user_born_time.present?
    #   if user_born_time > 1.days.ago.to_date
    #     errors.add(:user_born_time, 'should be over 1 day old')
    #   elsif user_born_time < 300.years.ago.to_date
    #     errors.add(:user_born_time, 'should be less than 300 years old')
    #   end
    # end
  end

  # def after_database_authentication; user_soft_restore! if user_soft_deleted?; end

  def user_soft_deleted?; !!deleted_at; end
  def soft_delete!; update_attribute(:deleted_at, Time.current); true; end
  def user_soft_restore!; update_attribute(:deleted_at, nil); true; end
  def user_full_deletion_time; (deleted_at + 10.days); end

  def hard_deleted?; (deleted_with_email && email && email.match(/^deleted_\d$/)); end
  def run_user_hard_delete!
    if id && id.positive? && user_soft_deleted? && (!(hard_deleted?))
      upd_sql = "UPDATE users SET deleted_with_email=email, email='deleted_#{ id }', encrypted_password='' WHERE id=#{ id }"
      sql_result = ActiveRecord::Base.connection.execute(upd_sql)
      # puts "\n\n\n\n upd_sql=[upd_sql] sql_result=[#{ sql_result }] \n\n\n"
      reload
      # update_attribute(:deleted_with_email, email)
      # skip_confirmation_notification!
      # update_attribute(:email, "deleted_#{ id }")
      %w{reset_password_token unlock_token confirmation_token locked_at}.each { |x| update_attribute(x, nil) }
      return true
    end
    false
  end

  # def user_born_time_date_str; (user_born_time || (Time.now - 18.years)).localtime.strftime("%F").html_safe; end
  def self.no_profile_avatar_sm_url; Rails.application.routes.url_helpers.root_url + "pics/no_image.png"; end

  def avatar_thumb(size: 100)
    avatar.variant(resize: "#{size}x#{size}")
  end
end
