# frozen_string_literal: true

class UserMinSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at
end
