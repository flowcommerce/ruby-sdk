#!/usr/bin/env ruby

# Create a new default shipping configuration for use in logistics v2.
# Migrates all experiences to use the default shipping configuration.
#
# For orgs with configured experiments involving shipping, it will need to
# be manually configured for now.
#
# Example:
#  ./migrate-logistics.rb test-org-1 test-org-2
#
require 'flowcommerce'

org = ARGV.shift.to_s.strip

if org.empty?
  puts "usage: migrate-logistics.rb <organization id>"
  exit(1)
end

# Assume API keys are located in ~/.flow/<org id>
def client(org)
  path = File.expand_path("~/.flow/%s" % org)
  if !File.exists?(path)
    puts "Error: Expected API token for org %s to be in file at %s" % [org, path]
    exit(1)
  end
  FlowCommerce.instance(:token => IO.read(path).strip)
end

# function to get all the experiences
def each_experience(client, org, limit=200, offset=0, &block)
  all = client.experiences.get(org, :limit => limit, :offset => offset)

  all.each do |exp|
    yield exp
  end

  if all.size >= limit
    each_experience(client, org, limit, offset + limit, &block)
  end
end

def default_shipping_configuration(client, org)
  form = ::Io::Flow::V0::Models::ShippingConfigurationForm.new(
    :name => "default"
  )
  client.shipping_configurations.put_by_key(org, "default", form)
end

# get a client for the organziation
client = client(org)

# upsert the default shipping configuration
default_config = default_shipping_configuration(client, org)
puts default_config.to_json
raise "--------------------------------------------"

# iterate through all the experiences
each_experience(client, org) do |exp|
  puts "ORG[#{org}] EXPERIENCE[#{exp.key}] INSPECT: #{exp.to_json}"
  client.tiers.get(org, :experience => exp.key).each do |tier|
    puts "TIER: #{tier.name}"
  end
  puts "======================================================================================="
end
