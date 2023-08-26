# frozen_string_literal: true

class Vehicle < ApplicationRecord
  NO_LOGO_IMG_PATH = '/pics/no_image.png'.freeze

  belongs_to :user
  has_many :vehicle_imgs, -> { order(prio: :asc, id: :asc) }, dependent: :destroy
  scope :active, -> { where(deleted_at: nil) }

  validates :name, length: { in: 2..160 }, presence: true
  validates :vehicle_description_text, length: { maximum: 2000 }
  validates :vehicle_seats_cnt, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 200_000, only_integer: true }, presence: true

  def client_default_url; "/vehicles/#{ id }"; end
  def self.profile_list_url; '/profile/my_vehicles'; end
  def profile_default_url; "#{ self.class.profile_list_url }/#{ id ? id : 'new' }"; end
  def profile_vehicle_images_list_url; "#{ profile_default_url }/vehicle_imgs"; end
  def client_vehicle_name_html; "<span class='client_vehicle_name_span'>Vehicle \##{ id }</span>".html_safe; end
  def can_owner_attach_image?; (valid_vehicle_imgs.count < user.event_max_images_cnt); end
  def logo_img_index; 0; end


  def valid_vehicle_imgs; vehicle_imgs.select(&:image_valid?); end
end
