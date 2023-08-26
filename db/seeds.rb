# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.development?
  unless AdminUser.find_by(email: 'admin@example.com')
    AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
  end
end

unless User.find_by(email: 'megatester@test.test')
  megatester = User.new(name: 'megatester', email: 'megatester@test.test', password: '123123', password_confirmation: '123123')
  megatester.skip_confirmation!
  megatester.save!
end

megatester = User.find_by(email: 'megatester@test.test')
[{ name: 'sprinter1' }, { name: 'sprinter2' }].each do |vdata|
  vehicle_tmp = megatester.vehicles.find_by(name: vdata[:name])
  unless vehicle_tmp
    new_vehicle = megatester.vehicles.create!({ name: vdata[:name], vehicle_seats_cnt: 200 })
    (0..3).each do |im_indx|
      fname = "#{ vdata[:name] }_#{ im_indx }.jpg"
      new_img = new_vehicle.vehicle_imgs.create!({ name: fname, prio: im_indx })
      # VehicleImg.find(2).image_file.attach(io: File.open(Rails.root.join('public', 'seed_files', 'vehicles', 'sprinter1_0.jpg')), filename: 'sprinter1_0.jpg')
      new_img.image_file.attach(io: File.open(Rails.root.join('public', 'seed_files', 'vehicles', fname)), filename: fname)
    end
  end
end

[{ lat: '48.027350092740541', lng: '33.461114086808813', name: 'Kulikovskaya street, 25', descr: 'Kulikovskaya street, house 25' },
 { lat: '47.974146870899837', lng: '33.435759572908246', name: '173', descr: 'bus-stop "173 quarter"' },
 { lat: '47.908656499915438', lng: '33.343162566230284', name: 'emancipation station', descr: 'release or liberation or exemption square at the old center of my native town Kryviy Rih.' }
].each_with_index do |sdata, indx|
  station_tmp = megatester.user_stations.find_by(name: sdata[:name])
  unless station_tmp
    attrs = { name: sdata[:name], station_description_text: sdata[:descr],
              station_lat_f64: BigDecimal(sdata[:lat].to_d),
              station_lng_f64: BigDecimal(sdata[:lng].to_d) }
    new_station = megatester.user_stations.create!(attrs)
    (0..2).each do |im_indx|
      fname = "station#{ indx }_#{ im_indx }.jpg"
      new_img = new_station.user_station_imgs.create!({ name: fname, prio: im_indx })
      new_img.image_file.attach(io: File.open(Rails.root.join('public', 'seed_files', 'stations', fname)), filename: fname)
    end
  end
end

[{ name: 'Kulikovskaya 25 - emancipation station', descr: 'Route from Kulikovskaya to emancipation' },
 { name: 'emancipation station - Kulikovskaya 25', descr: 'Route from emancipation to Kulikovskaya' }].each_with_index do |item, sub_indx|
  route_tmp = megatester.user_routes.find_by(name: item[:name])
  unless route_tmp
    attrs = { name: item[:name], route_description_text: item[:descr] }
    new_item = megatester.user_routes.create!(attrs)
    (0..2).each do |indx|
      station_id = megatester.user_stations[indx].id
      if sub_indx.eql?(1)
        station_id = megatester.user_stations[2 - indx].id
      end
      sattrs = { user_station_id: station_id, after_start_planned_seconds: 300 * indx, station_stay_seconds: 20 * indx }
      new_item.user_route_points.create!(sattrs)
    end
  end
end

2.times do |indx|
  vehicle_id = megatester.vehicles[indx].id
  u_route_id = megatester.user_routes[indx].id
  attrs = { vehicle_id: vehicle_id, user_route_id: u_route_id }
  trip_tmp = megatester.trips.find_by(attrs)
  unless trip_tmp
    Trip.create!(attrs.merge({ starts_at_unix: (Time.now + 2.hours).localtime.to_i, published: indx }))
  end
end

