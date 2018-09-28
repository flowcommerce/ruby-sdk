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
    puts "Error: Token for org %s not in path %s" % [org, path]
    exit(1)
  end
  FlowCommerce.instance(:token => IO.read(path).strip)
end

# function to get all the experiences
def each_experience(client, org, limit=200, offset=0, &block)
  all = client.experiences.get(org, :limit => limit, :offset => offset)

  all.each do |exp|
    next if exp.status != ::Io::Flow::V0::Models::ExperienceStatus.active
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

def tiers(client, org, exp)
  client.tiers.get(org, :experience => exp.key)
end

def create_shipping_lane(client, org, exp, default_config)
  client.shipping_configurations.post_lanes_by_key(
    org,
    default_config.key,
    ::Io::Flow::V0::Models::ShippingLaneForm.new(
      :from => "*",
      :to => exp.region.id
    )
  )
end

def create_tier(client, org, exp, shipping_lane, old_tier)
  rules = old_tier.rules.map do |rule|
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
    :currency => old_tier.currency,
    :integration =>  old_tier.integration,
    :name => old_tier.name,
    :rules => rules,
    :services => old_tier.services.map(&:id),
    :strategy =>  old_tier.strategy,
    :visibility =>  old_tier.visibility,
    :description =>  old_tier.description,
    :direction =>  old_tier.direction,
    :display => old_tier.display.to_hash,
    :shipping_lane => shipping_lane.id
  )

  client.tiers.post(org, form)
end

# get a client for the organziation
client = client(org)

# upsert the default shipping configuration
default_config = default_shipping_configuration(client, org)

# iterate through all the experiences
each_experience(client, org) do |exp|
  puts "ORG[#{org}] EXPERIENCE[#{exp.key}]"

  # create the shipping lane
  # one per old experience as a placeholder for tiers
  shipping_lane = create_shipping_lane(client, org, exp, default_config)

  # iterate through the tiers and create new ones in the shipping lane
  tiers(client, org, exp).each do |tier|
    puts "    TIER: #{tier.name}"
    create_tier(client, org, exp, shipping_lane, tier)
  end
  puts "=========" * 12
end

# sleep for a few seconds
seconds = 20
puts "SLEEPING FOR #{seconds} SECONDS TO WAIT FOR EVENTS TO PROPAGATE"
sleep(seconds)

# iterate through experiences again and assign logistics settings
each_experience(client, org) do |exp|
  next if exp.status != ::Io::Flow::V0::Models::ExperienceStatus.active
  form = ::Io::Flow::V0::Models::ExperienceLogisticsSettingsPutForm.new(
    :shipping_configuration_key => default_config.key
  )
  client.experience_logistics_settings.put(org, exp.key, form)
  puts "Updated Experience[#{exp.key}] to new default shipping configuration"
end
