# frozen_string_literal: true

class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :last_name, :avatar_thumb_url, :password_changed_at_unixtime,
    :bio, :phone, :gender, :facebook_link, :instagram_link, :created_at_unixtime

  def avatar_thumb_url
    url_helpers.url_for(object.avatar_thumb) if object.avatar.attached?
  end

  private

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
