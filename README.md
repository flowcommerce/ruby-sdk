# flow-ruby

Native ruby client to the Flow API (https://api.flow.io)

    require 'flowcommerce'

    client = FlowCommerce.client("api token")

    catalog = client.catalogs.get_catalog("demo")

    items = client.view_items.get("demo", "canada", :limit => 10, :offset => 0)
    puts "# items in view: %s" % items.size

See example.rb for a working example
