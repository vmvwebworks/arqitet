Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = Rails.application.credentials.dig(:braintree, :merchant_id)
Braintree::Configuration.public_key  = Rails.application.credentials.dig(:braintree, :public_key)
Braintree::Configuration.private_key = Rails.application.credentials.dig(:braintree, :private_key)
