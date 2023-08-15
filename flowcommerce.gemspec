$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'flow_commerce/version'

Gem::Specification.new do |s|
  s.name              = 'flowcommerce'
  s.homepage          = "https://github.com/flowcommerce/ruby-sdk"
  s.version           = FlowCommerce::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Native ruby client for the Flow REST API."
  s.description       = "Native ruby client for the Flow REST API. Detailed information at https://app.apibuilder.io/flow/api"
  s.authors           = ["Flow Commerce, Inc."]
  s.email             = 'tech@flow.io'
  s.licenses          = 'MIT'

  s.add_dependency('json')

  s.files             = %w( README.md )
  s.files             += Dir.glob("lib/**/*")
end
