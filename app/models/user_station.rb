# frozen_string_literal: true

class UserStation < ApplicationRecord
  NO_LOGO_IMG_PATH = '/pics/no_image.png'.freeze

  belongs_to :user
  has_many :user_station_imgs, -> { order(prio: :asc, id: :asc) }, dependent: :destroy

  scope :active, -> { where(deleted_at: nil) }

  before_validation :refill_lat_lng_ints
  validates :name, length: { in: 2..160 }, presence: true
  validates :station_description_text, length: { maximum: 2000 }
  validates :station_lat_f64, numericality: { greater_than_or_equal_to:  -90, less_than_or_equal_to:  90 }, presence: true
  validates :station_lng_f64, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, presence: true
  validates :station_lat, numericality: { only_integer: true }, presence: true
  validates :station_lng, numericality: { only_integer: true }, presence: true

  def refill_lat_lng_ints
    write_attribute(:station_lat, BigDecimal(sprintf('%.15f', station_lat_f64)).lat_lng_to_int_p7)
    write_attribute(:station_lng, BigDecimal(sprintf('%.15f', station_lng_f64)).lat_lng_to_int_p7)
  end

  def client_default_url; "/stations/#{ id }"; end
  def self.profile_list_url; '/profile/my_stations'; end
  def profile_default_url; "#{ self.class.profile_list_url }/#{ id ? id : 'new' }"; end
  def profile_station_images_list_url; "#{ profile_default_url }/station_imgs"; end
  def client_station_name_html; "<span class='client_station_name_span'>Station \##{ id }</span>".html_safe; end
  def can_owner_attach_image?; (valid_station_imgs.count < user.event_max_images_cnt); end
  def logo_img_index; 0; end


  def valid_station_imgs; user_station_imgs.select(&:image_valid?); end
  def station_logo_sm_url; valid_station_imgs.any? ? valid_station_imgs.first.image_sm_url : NO_LOGO_IMG_PATH; end
  def station_latitude; station_lat.int_p7_to_lat_lng; end
  def station_longitude; station_lng.int_p7_to_lat_lng; end
  def coords_absent?; station_lat_f64.zero? && station_lng_f64.zero?; end

  def station_coords_html
    "<span class='station_coords_span'>
      #{ sprintf('%.15f', station_lat_f64) },#{ sprintf('%.15f', station_lng_f64) }
    </span>".html_safe
  end
end
