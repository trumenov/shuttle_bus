class Geocoder::Result::Base
  def read_attribute_for_serialization(attr)
    return SecureRandom.hex if attr == :id
  end
end
