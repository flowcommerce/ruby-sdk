#!/usr/bin/env ruby

require 'flowcommerce'

token_file = "~/.flow/token"

if !File.exists?(File.expand_path(token_file))
  puts "ERROR: Pls create a file named %s containing your Flow API token" % token_file
  exit(1)
end

token = IO.read(File.expand_path(token_file)).strip

client = FlowCommerce.client(token)

catalog = client.catalogs.get_catalog("chloe")
puts "Master catalog: " + catalog.inspect
puts ""

view = client.views.get("chloe", :key => "canada").first

if view.nil?
  form = Io::Flow::Catalog::V0::Models::ViewForm.new(
    :key => "canada",
    :countries => ["CA"],
    :currency => "CAD",
    :query => "Jewelry",
    :settings => Io::Flow::Catalog::V0::Models::ViewSettingsForm.new()
  )
  view = client.views.post("chloe", form)
end

puts "Canada view: " + view.inspect
puts ""

items = client.view_items.get("chloe", "canada", :limit => 10, :offset => 0)
puts "# items in view: %s" % items.size
items.each do |item|
  puts " - item %s"
end
