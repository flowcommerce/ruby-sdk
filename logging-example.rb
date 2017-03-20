#!/usr/bin/env ruby

# Example illustrating the use of a custom HTTP Handler
# to log requests

load 'lib/flowcommerce.rb'
load 'lib/logging_http_client.rb'

client = FlowCommerce.instance(:http_handler => LoggingHttpClient)

# Our custon http client will log a message to stdout
# for every HTTP Call
client.organizations.get
