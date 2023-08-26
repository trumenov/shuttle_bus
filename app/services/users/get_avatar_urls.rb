# frozen_string_literal: true

module Users
  class GetAvatarUrls
    prepend BasicService

    include Rails.application.routes.url_helpers

    param :avatar

    def call
      {
        small_url: small_url,
        medium_url: medium_url,
        url: rails_blob_url(avatar)
      }
    end

    private

    def small_url
      return rails_blob_url(avatar) unless avatar.variable?
      rails_representation_url(avatar.variant(resize_to_limit: [50, 50]).processed)
    end

    def medium_url
      return rails_blob_url(avatar) unless avatar.variable?
      rails_representation_url(avatar.variant(resize_to_limit: [140, 140]).processed)
    end
  end
end
