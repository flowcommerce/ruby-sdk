load File.join(File.dirname(__FILE__), 'copy_experience_util.rb')

module CopyExperiences

  def CopyExperiences.run(client, org)
    target_org = Util::Ask.for_string("What is the org key to which to copy experiences? ")

    # base and target cannot be the same
    if org == target_org
      raise "Base organization[#{org}] and target organization[#{target_org}] cannot be the same"
    end

    target_token = Util::Ask.for_string("Please paste token for #{target_org}: ", :echo => false)
    target_client = FlowCommerce.instance(:token => target_token)

    # get all experiences from base org
    experiences = client.experiences.get(org, :limit => 100, :order => "position")
    max = experiences.size

    # iterate through experiences
    experiences.each_with_index do |exp, i|
      puts "[#{i+1}/#{max}] Experience key[#{exp.key}] from base org[#{org}] to target org[#{target_org}]"

      CopyExperienceUtil.copy_experience(client, org, target_client, target_org, exp)
      CopyExperienceUtil.copy_pricing(client, org, target_client, target_org, exp)
      CopyExperienceUtil.copy_tiers(client, org, target_client, target_org, exp)

      puts ""
    end
  end
end
