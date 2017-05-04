load File.join(File.dirname(__FILE__), 'copy_experience_util.rb')

module CopyOneExperience

  def CopyOneExperience.run(client, org)
    existing_key = Util::Ask.for_string("What is the existing experience key? ")
    new_key = Util::Ask.for_string("What is the new experience key? ")

    experiences = client.experiences.get(org, :key => [existing_key, new_key], :limit => 1)
    existing = experiences.find { |e| e.key == existing_key }
    if existing.nil?
      puts "ERROR: Could not find experience with key '%s'" % existing_key
      exit(1)
    end

    if experiences.find { |e| e.key == new_key }
      puts "ERROR: Experience with key '%s' already exists" % new_key
      exit(1)
    end

    new_name = Util::Ask.for_string("What is the new experience name? ")
    target = existing.copy( :key => new_key, :name => new_name )
    
    CopyExperienceUtil.copy_experience(client, org, client, org, target)
    CopyExperienceUtil.copy_pricing(client, org, client, org, target)
    CopyExperienceUtil.copy_tiers(client, org, client, org, target)
  end

end
