Apipie.configure do |config|
  config.app_name                = "SearchEngine"
  config.app_info                = "Documentation to API"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.translate = false
  config.validate = false
end
