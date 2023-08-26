module JWT
  class Verify
    def initialize(payload, options)
      @payload = payload.is_a?(Integer) ? { tmp_param_if_payload_is_a_int: payload } : payload
      @options = DEFAULTS.merge(options)
    end
  end
end

class JsonWebToken
 class << self
   def encode(data, exp = 2.years.from_now)
     # payload[:exp] = exp.to_i
     JWT.encode(data[:user_id], Rails.application.secrets.secret_key_base)
   end

   def decode(token)
    user_id = JWT.decode(token, Rails.application.secrets.secret_key_base, true, { verify_expiration: false })[0].to_s.to_i || 0
    # puts "\n\n\n user_id=[#{ user_id }] \n\n\n"
     # HashWithIndifferentAccess.new body
    user_id
   rescue
     nil
   end
 end
end
