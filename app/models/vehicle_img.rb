# frozen_string_literal: true

class VehicleImg < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :vehicle
  has_one_attached :image_file
  # has_one_attached :image_file_sm

  def image_valid?; deleted_at.nil? && image_file.attached?; end

  def image_file_disk_path; ActiveStorage::Blob.service.send(:path_for, image_file.key); end
  def image_sm_url; "/vehicle_img_sm/#{ id }?v=#{ updated_at.to_i }"; end
  def image_full_url; rails_blob_path(image_file , only_path: true); end
end
