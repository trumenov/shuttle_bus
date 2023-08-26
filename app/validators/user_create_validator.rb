class UserCreateValidator
  include ActiveModel::Validations
  validates :email, format: { with: /\A[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\z/ }, presence: true, length: { in: 5..100 }
  validates :password, presence: true, length: { in: 6..50 }

  attr_reader :data

  def initialize(data_in)
    @data = data_in
  end

  def read_attribute_for_validation(key)
    @data[key]
  end
end
