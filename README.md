# flow-ruby

Native ruby client to the Flow API (https://api.flow.io)

## Status

Please note that this library and APIs are in ALPHA and are subject to
change and will break in the future. Once Flow Commerce releases its
official 1.0 library, API changes will be backwards compatible. Until
then - we are super grateful for your patience as we finalize the API
for our launch.

## Installation

    gem install flowcommerce

    require 'flowcommerce'

    client = FlowCommerce.instance(:token => "<YOUR API TOKEN>")
    client.items.get("<YOUR ORGANIZATION ID>", :limit => 5, :offset => 0).each do |i|
      puts i.number
    end
     

## Running the Examples in this Repository

    1. Create a file named ~/.flow/token that contains your API token
       and nothing else

    2. ruby ./example.rb <org id>

Code for each example is in the examples directory, designed to really
highlight the use of key APIs in as clear a way as possible.


## Documentation

Complete API documentation is available at https://docs.flow.io

## Debugging / Issues

### IPv6

Please disable IPv6. We are currently working on IPv6 compatibility for the APIs.

#### Mac OS

If you are seeing very slow (multi-second response times), it might be this: [Net::HTTP extremely slow responses for HTTPS requests](http://stackoverflow.com/questions/29945204/nethttp-extremely-slow-responses-for-https-requests)

The solution is to run

```networksetup -setv6off Wi-Fi```

#### Ububtu

[https://support.purevpn.com/how-to-disable-ipv6-linuxubuntu](https://support.purevpn.com/how-to-disable-ipv6-linuxubuntu)
