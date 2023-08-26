# frozen_string_literal: true

addresses = {
  '230 West 43rd St., New York City' => {
    'lat' => '40.7573862',
    'lon' => '-73.9881256',
    'display_name' => '230 West 43rd St., New York City, NY 10036',
    'address' => {
      'street' => 'West 43rd St.',
      'city' => 'New York City',
      'state' => 'New York',
      'state_code' => 'NY',
      'country' => 'United States',
      'country_code' => 'US',
      'house_number' => '230'
    }
  },
  [40.75747130000001, -73.9877319] => {
    'lat' => '40.75747130000001',
    'lon' => '-73.9877319',
    'display_name' => '229 West 43rd St., New York City, NY 10036',
    'address' => {
      'street' => 'West 43rd St.',
      'city' => 'New York City',
      'state' => 'New York',
      'state_code' => 'NY',
      'country' => 'United States',
      'country_code' => 'US',
      'house_number' => '229'
    }
  },
  'Worthington, OH' => {
    'lat' => '40.09846115112305',
    'lon' => '-83.01747131347656',
    'display_name' => 'Worthington, OH',
    'address' => {
      'street' => '',
      'city' => 'Worthington',
      'state' => 'Ohio',
      'state_code' => 'OH',
      'country' => 'United States',
      'country_code' => 'US',
      'house_number' => nil
    }
  }
}

Geocoder.configure(lookup: :test, ip_lookup: :test)
addresses.each { |lookup, results| Geocoder::Lookup::Test.add_stub(lookup, [results]) }
