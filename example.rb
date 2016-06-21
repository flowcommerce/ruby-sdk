#!/usr/bin/env ruby

#require 'flowcommerce'

load 'lib/flowcommerce.rb'

token_file = "~/.flow/token"

if !File.exists?(File.expand_path(token_file))
  puts "ERROR: Pls create a file named %s containing your Flow API token" % token_file
  exit(1)
end

org = ARGV.shift.to_s.strip
if org == ""
  puts "ERROR: Pls specify your organization"
  exit(1)
end

token = IO.read(File.expand_path(token_file)).strip

if token == ""
  puts "ERROR: API Token not found. Expected in file %s" % token_file
  exit(1)
end

client = FlowCommerce.client(token)

def pick_n(n, items)
  items.shuffle.first(2)
end

def create_items(client, org, number_items=10)

  currencies = ["USD", "CAD", "AUD", "GBP"]

  number_items.times do |i|
    number = "sku-" + Time.now.strftime("%Y%m") + "-" + rand(10000).to_s
    puts " - creating item %s/%s" % [org, number]
    
    client.items.put_by_id(org,
                           number,
                           ::Io::Flow::Catalog::V0::Models::ItemForm.new(
                             :number => number,
                             :locale => "en_US",
                             :name => "Flow Test Item #{number}",
                             :currency => currencies.shuffle.first,
                             :price => 100 + rand(120),
                             :categories => pick_n(2, ["Apparel", "Accessories", "Mens", "Womens", "Belts", "Special"]),
                           )
                        )
  end

  exit(1)
end

create_items(client, org, 175)

def each_record(f, limit=100, offset=0, &block)
  records = f.call(limit + 1, offset)
  have_more = records.size > limit

  records[0...-1].each do |rec|
    yield rec
  end

  if !records.empty?
    each_record(f, limit, offset += limit, &block)
  end
end

def display_items(client)
  numbers = []
  each_record( Proc.new do |limit, offset|
                 client.items.get(org, :limit => limit, :offset => offset)
               end
             ) do |rec|
    numbers << rec.number
  end
end

exit(1)

def delete_all_items
  while true
    puts "Fetching 100 items from master catalog"
    items = client.items.get(org, :limit => 100)
    items.each do |item|
      puts " - Deleting %s/%s" % [org, item.number]
      client.items.delete_by_id(org, item.number)
    end

    if items.empty?
      break
    end
  end
  exit(1)
end

subcatalog = client.subcatalogs.get(org, :key => ["canada"]).first

if subcatalog.nil?
  form = Io::Flow::Catalog::V0::Models::SubcatalogForm.new(:country => "canada")
  subcatalog = client.subcatalogs.post(org, form)
end

puts ""
puts "Listing up to 10 items in the canada subcatalog"

items = client.subcatalog_items.get(org, "canada", :limit => 10, :offset => 0)

items.each_with_index do |item, i|
  puts item.inspect
  puts "  %s. item %s: %s %s" % [i, item.number, item.price.amount, item.currency]
end


puts ""
puts "Searching by specific item number"

items = client.subcatalog_items.get(org, "canada", :number => ['R030G-8', 'R028CL-7'])

items.each_with_index do |item, i|
  puts item.inspect
  puts "  %s. item %s: %s %s" % [i, item.number, item.price.amount, item.currency]
end
