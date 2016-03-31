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

subcatalog = client.subcatalogs.get(org, :key => "canada").first

if subcatalog.nil?
  form = Io::Flow::Catalog::V0::Models::SubcatalogForm.new(
    :key => "canada",
    :query => "Jewelry",
    :settings => Io::Flow::Catalog::V0::Models::SubcatalogSettingsForm.new()
  )
  subcatalog = client.subcatalogs.post(org, form)
end

puts ""
puts "Listing up to 10 items in the canada subcatalog"

items = client.subcatalog_items.get(org, "canada", :limit => 10, :offset => 0)

items.each_with_index do |item, i|
  puts "  %s. item %s: %s %s" % [i, item.number, item.price.amount, item.currency]
end


puts ""
puts "Searching by specific item number"

items = client.subcatalog_items.get(org, "canada", :number => ['R030G-8', 'R028CL-7'])

items.each_with_index do |item, i|
  puts "  %s. item %s: %s %s" % [i, item.number, item.price.amount, item.currency]
end
