class UserChangePassValidator
  include ActiveModel::Validations
  validates :password, presence: true, length: { in: 6..50 }
  validates :password_confirmation, :presence => true
  # validates_confirmation_of :password

  attr_reader :data
  attr_reader :user


  def initialize(user_in, data_in)
    @user = user_in
    @data = data_in
  end

  def valid?
    result = super()
    if errors.empty?
      if @data[:password].str_eq?(@data[:password_confirmation])
        unless @user.current_password_unknown.positive?
          unless @user.valid_password?(@data[:current_password])
            errors.add(:current_password, 'not valid')
          end
        end
      else
        errors.add(:password_confirmation, 'not equal to new password')
      end
    end
    errors.empty?
  end

  def read_attribute_for_validation(key)
    @data[key]
  end
end
