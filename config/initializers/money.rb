# Configuración de Money gem
MoneyRails.configure do |config|
  # Configuración básica
  config.default_currency = :eur
  config.rounding_mode = BigDecimal::ROUND_HALF_UP

  # Configuración de formato
  config.locale_backend = :currency
  config.raise_error_on_money_parsing = false
  config.default_format = {
    no_cents_if_whole: true,
    symbol: true,
    sign_before_symbol: false
  }
end
