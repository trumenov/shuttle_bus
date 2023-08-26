class ActiveMerchant::Billing::StripeGateway < ActiveMerchant::Billing::Gateway
  def scrub(transcript)
    transcript.
      gsub(%r((Authorization: Basic )\w+), '\1[FILTERED]').
      gsub(%r((Authorization: Bearer )\w+), '\1[FILTERED]').
      gsub(%r((&?three_d_secure\[cryptogram\]=)[\w=]*(&?)), '\1[FILTERED]\2').
      gsub(%r(((\[card\]|card)\[cryptogram\]=)[^&]+(&?)), '\1[FILTERED]\3').
      gsub(%r(((\[card\]|card)\[cvc\]=)\d+), '\1[FILTERED]').
      gsub(%r(((\[card\]|card)\[emv_approval_data\]=)[^&]+(&?)), '\1[FILTERED]\3').
      gsub(%r(((\[card\]|card)\[emv_auth_data\]=)[^&]+(&?)), '\1[FILTERED]\3').
      gsub(%r(((\[card\]|card)\[encrypted_pin\]=)[^&]+(&?)), '\1[FILTERED]\3').
      gsub(%r(((\[card\]|card)\[encrypted_pin_key_id\]=)[\w=]+(&?)), '\1[FILTERED]\3').
      gsub(%r(((\[card\]|card)\[number\]=)\d+), '\1[FILTERED]').
      gsub(%r(((\[card\]|card)\[swipe_data\]=)[^&]+(&?)), '\1[FILTERED]\3')
  end

  def headers(options = {})
    key = options[:key] || @api_key
    idempotency_key = options[:idempotency_key]

    headers = {
      # 'Authorization' => 'Basic ' + Base64.strict_encode64(key.to_s + ':').strip,
      'Authorization' => 'Bearer ' + key.to_s.strip,
      'User-Agent' => "Stripe/v1 ActiveMerchantBindings/#{ActiveMerchant::VERSION}",
      'Stripe-Version' => api_version(options),
      'X-Stripe-Client-User-Agent' => stripe_client_user_agent(options),
      'X-Stripe-Client-User-Metadata' => { ip: options[:ip] }.to_json
    }
    headers['Idempotency-Key'] = idempotency_key if idempotency_key
    headers['Stripe-Account'] = options[:stripe_account] if options[:stripe_account]
    headers
  end

end