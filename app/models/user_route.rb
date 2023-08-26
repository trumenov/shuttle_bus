# frozen_string_literal: true

class UserRoute < ApplicationRecord
  NO_LOGO_IMG_PATH = '/pics/no_image.png'.freeze

  scope :active, -> { where(deleted_at: nil) }

  belongs_to :user
  has_many :user_route_points, -> { order(after_start_planned_seconds: :asc, id: :asc) }, dependent: :destroy
  has_many :trips

  validates :name, length: { in: 2..160 }, presence: true
  validates :route_description_text, length: { maximum: 2000 }

  def client_default_url; "/routes/#{ id }"; end
  def self.profile_list_url; '/profile/my_routes'; end
  def profile_default_url; "#{ self.class.profile_list_url }/#{ id ? id : 'new' }"; end
  def client_route_name_html; "<span class='client_route_name_span'>Route \##{ id }</span>".html_safe; end
  def valid_route_points; user_route_points.select { |x| x.point_valid? }; end
  def image_sm_url; "/user_route_img_sm/#{ id }?v=#{ updated_at.to_i }"; end
  def valid_points_imgs; valid_route_points.map { |x| x.user_station.valid_station_imgs.first }.compact; end

  def route_run_seconds
    return 0 unless user_route_points.any?
    last_point = user_route_points.last
    last_point.after_start_planned_seconds + last_point.station_stay_seconds
  end
end
