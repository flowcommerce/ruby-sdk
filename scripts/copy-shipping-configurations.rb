#!/usr/bin/env ruby

# Copies shipping configurations from a source org to a target org
#
# Example:
#  ./copy-shipping-configurations.rb test-org-1 test-org-2
#
require 'flowcommerce'

source_org = ARGV.shift.to_s.strip
target_org = ARGV.shift.to_s.strip

if source_org.empty? || target_org.empty?
  puts "usage: copy-shipping-configurations.rb <source organization id> <target organization id>"
  exit(1)
else
  puts "Copying shipping configurations from #{source_org} to #{target_org}"
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

# function to get all the shipping configurations
def each_shipping_configuration(client, org, limit=200, offset=0, &block)
  all = client.shipping_configurations.get(org, :limit => limit, :offset => offset)

  all.each do |sc|
    yield sc
  end

  if all.size >= limit
    each_shipping_configuration(client, org, limit, offset + limit, &block)
  end
end

# function to get all the shipping lanes in a configuration
def each_shipping_lane(client, org, sc, limit=200, offset=0, &block)
  all = client.shipping_configurations.get_lanes_by_key(org, sc.key, :limit => limit, :offset => offset)

  all.each do |sl|
    yield sl
  end

  if all.size >= limit
    each_shipping_lane(client, org, sc, limit, offset + limit, &block)
  end
end

# create or get the default shipping configuration
def default_shipping_configuration(client, org)
  # find the default configuration
  default_sc = nil
  each_shipping_configuration(client, org) do |sc|
    if sc.type == ::Io::Flow::V0::Models::ShippingConfigurationType.default
      default_sc = sc
    end
  end

  # find the default or create it
  if default_sc.nil?
    form = ::Io::Flow::V0::Models::ShippingConfigurationForm.new(:name => "default")
    client.shipping_configurations.put_by_key(org, "default", form)
  else
    default_sc
  end
end

# delete all variant configurations delete all lanes in default from target org
def cleanup_shipping_configurations(client, org)
  puts "Cleaning up configurations and lanes for org #{org}"
  # delete all the variant configurations
  each_shipping_configuration(client, org) do |sc|
    if sc.type == ::Io::Flow::V0::Models::ShippingConfigurationType.variant
      client.shipping_configurations.delete_by_key(org, sc.key)
      puts "Deleted variant shipping configuration #{sc.key} for org #{org}"
    end
  end

  # delete lanes only from default
  default_sc = default_shipping_configuration(client, org)
  each_shipping_lane(client, org, default_sc) do |lane|
    client.shipping_configurations.delete_lanes_by_key_and_id(org, default_sc.key, lane.id)
    puts "Deleted shipping lane #{lane.id} config #{default_sc.key} for org #{org}"
  end
  puts "Done cleaning up configurations and lanes for org #{org}"
end

# copy old tier to target shipping lane
def copy_tier_to_lane(client, org, source_tier, target_lane)
  rules = source_tier.rules.map do |rule|
    outcome = if rule.outcome.is_a?(::Io::Flow::V0::Models::AmountMargin)
      margin = ::Io::Flow::V0::Models::TierRuleOutcome.from_json(rule.outcome.to_hash).margin
      ::Io::Flow::V0::Models::AmountMarginForm.new(
        :margin => ::Io::Flow::V0::Models::Money.new(
          :currency => rule.margin.currency,
          :amount => rule.margin.amount
        )
      )
    elsif rule.outcome.is_a?(::Io::Flow::V0::Models::FlatRate)
      price = ::Io::Flow::V0::Models::TierRuleOutcome.from_json(rule.outcome.to_hash).price
      ::Io::Flow::V0::Models::FlatRateForm.new(
        :price => ::Io::Flow::V0::Models::Money.new(
          :currency => price.currency,
          :amount => price.amount
        )
      )
    else
      rule.outcome
    end

    ::Io::Flow::V0::Models::TierRuleForm.new(
      :position => rule.position,
      :query => rule.query,
      :outcome => outcome.to_hash
    )
  end

  form = ::Io::Flow::V0::Models::TierForm.new(
    :currency => source_tier.currency,
    :integration =>  source_tier.integration,
    :name => source_tier.name,
    :rules => rules,
    :services => source_tier.services.map(&:id),
    :strategy =>  source_tier.strategy,
    :visibility =>  source_tier.visibility,
    :description =>  source_tier.description,
    :direction =>  source_tier.direction,
    :display => source_tier.display.to_hash,
    :shipping_lane => target_lane.id
  )

  client.tiers.post(org, form)
end

# copy shipping lanes and tiers from one configuration to another
def copy_lanes(source_client, source_org, source_sc, target_client, target_org, target_sc)
  # for each shipping lane in the source org configuration
  each_shipping_lane(source_client, source_org, source_sc) do |source_lane|
    # copy over to the target org configuration
    shipping_lane_form = ::Io::Flow::V0::Models::ShippingLaneForm.new(
      :from => source_lane.query.q,
      :to => source_lane.region
    )
    target_lane = target_client.shipping_configurations.post_lanes_by_key(target_org, source_sc.key, shipping_lane_form)
    puts "Copied #{source_org} #{source_sc.key} lane #{source_lane.region} to #{target_org} #{target_sc.key} lane #{target_lane.region}"

    source_lane.tiers.each do |source_tier|
      copy_tier_to_lane(target_client, target_org, source_tier, target_lane)
    end
    puts "Copied tiers #{source_org} #{source_sc.key} lane #{source_lane.region} to #{target_org} #{target_sc.key} lane #{target_lane.region}"
  end
end

# copy all variant configurations and lanes
def copy_variant_configurations(source_client, source_org, target_client, target_org)
  each_shipping_configuration(source_client, source_org) do |source_sc|
    if source_sc.type == ::Io::Flow::V0::Models::ShippingConfigurationType.variant
      puts "Copying #{source_org} config #{source_sc.key} to #{target_org}"

      form = ::Io::Flow::V0::Models::ShippingConfigurationForm.new(:name => source_sc.name)
      target_sc = client.shipping_configurations.put_by_key(org, source_sc.key, form)

      copy_lanes(source_client, source_org, source_sc, target_client, target_org, target_sc)
      puts "Done #{source_org} config #{source_sc.key} to #{target_org}"
    end
  end
end

# get a client for the organziations
source_client = client(source_org)
target_client = client(target_org)

# delete all variant configurations delete all lanes in default from target org
cleanup_shipping_configurations(target_client, target_org)

# find default configurations for both orgs
source_default_sc = default_shipping_configuration(source_client, source_org)
target_default_sc = default_shipping_configuration(target_client, target_org)
copy_lanes(source_client, source_org, source_default_sc, target_client, target_org, target_default_sc)

# iterate through variant configurations - create variant and copy lanes
copy_variant_configurations(source_client, source_org, target_client, target_org)
