#!/usr/bin/env ruby

# Example illustrating the use of a custom HTTP Handler
# to log requests

load 'lib/flowcommerce.rb'
load 'extensions/logging_http_handler.rb'

logfile = "/tmp/test.log"
puts "Logging to %s" % logfile
client = FlowCommerce.instance(:http_handler => LoggingHttpHandler.new(logfile))

# Our custon http client will log a message to stdout
# for every HTTP Call
client.organizations.get
