#!/usr/bin/env ruby

# Copies experiences from a source org to a target org
#
# Example:
#  ./copy-experiences.rb test-org-1 test-org-2
#
require 'flowcommerce'

source_org = ARGV.shift.to_s.strip
target_org = ARGV.shift.to_s.strip

if source_org.empty? || target_org.empty?
  puts "usage: copy-experiences.rb <source organization id> <target organization id>"
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

def each_experience(client, org, limit=100, offset=0, &block)
  all = client.experiences.get(org, :limit => limit, :offset => offset)

  all.each do |exp|
    yield exp
  end

  if all.size >= limit
    each_experience(client, org, limit, offset + limit, &block)
  end
end

def does_experience_exist?(client, org, key)
  begin
    client.experiences.get_by_key(org, key)
    true
  rescue Io::Flow::V0::HttpClient::ServerError => e
    if e.code == 404
      false
    else
      raise e
    end
  end
end

# Creates a new experienece in the specified org based on the provided experience
def copy_experience(client, org, exp)
  form = ::Io::Flow::V0::Models::ExperienceForm.new(
    :region_id => exp.region.id,
    :name => exp.name,
    :key => exp.key,
    :delivered_duty => exp.delivered_duty,
    :country => exp.country,
    :currency => exp.currency,
    :language => exp.language,
    :measurement_system => exp.measurement_system
  )
  client.experiences.post(org, form)
end

source_client = client(source_org)
target_client = client(source_org)

each_experience(source_client, source_org) do |exp|
  puts "%s/%s" % [source_org, exp.key]
  if does_experience_exist?(target_client, target_org, exp.key)
    puts " - %s/%s already exists - skipping" % [target_org, exp.key]
  else
    puts " - %s/%s creating..." % [target_org, exp.key]
    copy_experience(target_client, target_org, exp)
    puts " - done - experience created"
  end
end
