#!/usr/bin/env ruby

# Grabs the current version of the API, downloads the latest and if
# there is a difference commits the new version. Used by our release
# script to document in the git commit exactly what the version change
# in the API was.
#
# Example:
#  ./update-apibuilder.rb
#

dir = File.dirname(__FILE__)

def extract_version(path)
  IO.readlines(path).each do |l|
    if md = l.strip.match(/apibuilder.+https\:\/\/.+\/flow\/api\/([\d\.]+)/i)
      return md[1]
    elsif md = l.strip.match(/apidoc.+http\:\/\/.+\/flow\/api\/([\d\.]+)/i)
      return md[1]
    end
  end

  puts "ERROR: Could not extract current version"
  exit(1)
end

path = File.join(dir, "../lib/flow_commerce/flow_api_v0_client.rb")
current = extract_version(path)
system("cd %s && apibuilder update" % File.join(dir, ".."))
latest = extract_version(path)

msg = []

if current == latest
  diff = `git diff lib/flow_commerce/flow_api_v0_client.rb`.strip
  if diff.empty?
    puts "apibuilder API version remains at %s" % current
    puts ""
    exit(1)
  end
  msg << "Update API Client Code"
else
  msg << "Update API version from %s to %s" % [current, latest]
  msg << ""
  msg << "  - See https://app.apibuilder.io/history?org=flow&app=api&from=%s&to=%s" % [current, latest]
end

system("git commit -m '%s' lib/flow_commerce/flow*rb" % msg.join("\n"))

