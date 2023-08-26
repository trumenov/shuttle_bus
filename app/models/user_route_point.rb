# frozen_string_literal: true

class UserRoutePoint < ApplicationRecord

  belongs_to :user_route
  belongs_to :user_station

  validates :user_route, presence: true, allow_blank: false
  validates :user_station, presence: true, allow_blank: false
  validates :after_start_planned_seconds, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 60*60*24*180, only_integer: true }, presence: true
  validates :station_stay_seconds, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 60*60*24*180, only_integer: true }, presence: true
  validate :validate_same_user_route_and_station

  def validate_same_user_route_and_station
    if errors.empty?
      unless user_route.user_id.eql?(user_station.user_id)
        errors.add(:user_id, 'should be same')
      end
    end
  end

  def rpoint_come_time_unix(trip_start_unix = 0); trip_start_unix + after_start_planned_seconds; end
  def rpoint_away_time_unix(trip_start_unix = 0); trip_start_unix + after_start_planned_seconds + station_stay_seconds; end
  def rpoint_come_time(trip_start_unix = 0); Time.at(rpoint_come_time_unix(trip_start_unix)).to_datetime.localtime; end
  def rpoint_away_time(trip_start_unix = 0); Time.at(rpoint_away_time_unix(trip_start_unix)).to_datetime.localtime; end

  def client_default_url; "/routes/#{ user_route_id }/route_point/#{ id }"; end
  def client_route_name_html; "<span class='client_route_point_name_span'>RoutePoint \##{ id }</span>".html_safe; end
  def point_valid?; deleted_at.nil?; end

  def visit_time_html(trip_start_unix = 0)
    "<span class='visit_time_span'>
      #{ rpoint_come_time(trip_start_unix).client_stamp_with_br_html }
      <span class='visit_time_delim'> - </span>
      #{ rpoint_away_time(trip_start_unix).client_stamp_with_br_html }
    </span>".html_safe
  end

  def route_logo_sm_url; user_station.station_logo_sm_url; end
end
