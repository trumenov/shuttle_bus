module ActiveAdmin::UserHelper
  # def minimum_user_age
  #   to_age(User.active.maximum(:user_born_time))
  # end

  # def maximum_user_age
  #   to_age(User.active.minimum(:user_born_time))
  # end

  # def average_user_age
  #   to_age(Time.at(User.active.average('UNIX_TIMESTAMP(user_born_time)')))
  # end

  # def to_age(date)
  #   ((Time.zone.now - date.to_time) / 1.year.seconds).floor
  # end
end
