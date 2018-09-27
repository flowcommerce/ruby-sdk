#!/usr/bin/env ruby

# Copies experiences from a source org to a target org
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

# function to get all tiers of the experience
def tiers(client, org, exp, limit=100, offset=0)
  client.tiers.get(org, :experience => exp.key, :limit => limit, :offset => offset)
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

# get a client for the organziation
client = client(org)

# iterate through all the experiences
each_experience(client, org) do |exp|
  puts "ORG[#{org}] EXPERIENCE[#{exp.key}] INSPECT: #{exp.to_json}"
  puts "-------"
  tiers(client, org, exp).each do |tier|
    puts "TIER: #{tier.name} INSPECT: #{tier.to_json}"
    puts "-------"
  end
  puts "======================================================================================="
end
