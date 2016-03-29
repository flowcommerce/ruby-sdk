# flow-ruby

Native ruby client to the Flow API (https://api.flow.io)

## Installation

    gem install flowcommerce


## Usage

    require 'flowcommerce'

    org = "demo"

    client = FlowCommerce.client("api token")

    catalog = client.catalogs.get_catalog(org)

    items = client.subcatalog_items.get(org, "canada", :limit => 10, :offset => 0)
    puts "# items in subcatalog: %s" % items.size


## Example

See example.rb for a working example


## Documentation

The full API is documented at http://apidoc.me/flow/catalog/latest

Also look at
https://github.com/flowcommerce/ruby-sdk/blob/master/lib/clients/flow_catalog_v0_client.rb
for the complete Ruby implementation of the API.


## Release a new version of the gem

    go run release.go

