#!/usr/bin/env ruby

require 'flowcommerce'

token_file = "~/.flow/token"

if !File.exists?(File.expand_path(token_file))
  puts "ERROR: Pls create a file named %s containing your Flow API token" % token_file
  exit(1)
end

token = IO.read(File.expand_path(token_file)).strip
org = "chloe"

client = FlowCommerce.client(token)

view = client.views.get(org, :key => "canada").first

if view.nil?
  form = Io::Flow::Catalog::V0::Models::ViewForm.new(
    :key => "canada",
    :countries => ["CA"],
    :currency => "CAD",
    :query => "Jewelry",
    :settings => Io::Flow::Catalog::V0::Models::ViewSettingsForm.new()
  )
  view = client.views.post(org, form)
end

puts "Canada view: " + view.inspect
puts ""

#items = client.view_items.get(org, "canada", :number => ['N305', 'N306'], :limit => 10, :offset => 0)
items = client.view_items.get(org, "canada", :limit => 10, :offset => 0)

items.each_with_index do |item, i|
  price = item.content.first.price
  puts "%s. item %s: %s %s" % [i, item.number, price.current.amount, price.current.currency]
end
