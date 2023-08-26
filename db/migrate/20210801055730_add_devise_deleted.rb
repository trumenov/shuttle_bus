# frozen_string_literal: true

class AddDeviseDeleted < ActiveRecord::Migration[6.0]
  def self.up
    change_table :users do |t|
      t.datetime :deleted_at, after: :updated_at
    end
  end
end
