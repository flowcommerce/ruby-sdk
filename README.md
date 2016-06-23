# flow-ruby

Native ruby client to the Flow API (https://api.flow.io)

## Status

Please note that this library and APIs are in ALPHA and are subject to
change and will break in the future. Once Flow Commerce releases its
official 1.0 library, API changes will be backwards compatible. Until
then - we are super grateful for your patience as we finalize the API
for our launch.

Additionally, note that the final URL for the Flow Commerce API will
be https://api.flow.io - at the moment this domain is not ready, thus
you will see different clients used to access the catalog or to access
experience. This is temporary.

## Installation

    gem install flowcommerce

    require 'flowcommerce'

    client = FlowCommerce.catalog_client("<YOUR API TOKEN>")
    client.items.get("<YOUR ORGANIZATION ID>", :limit => 5, :offset => 0).each do |i|
      puts i.number
    end
     

## Running the Examples in this Repository

    1. Create a file named ~/.flow/token that contains your API token
       and nothing else

    2. ruby ./example.rb <org id>

Code for each example is in the examples directory, designed to really
highlight the use of key APIs in as clear a way as possible.


## Documentation

Complete API documentation is available at http://docs.flow.io
