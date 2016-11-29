module DeleteExperience

  def DeleteExperience.run(client, org)
    experiences = client.experiences.get(org, :limit => 100, :order => "position")

    puts "Available Experiences to Delete: "
    experiences.each do |experience|
      puts "  - ID: #{experience.id}, KEY: #{experience.key}, Region: #{experience.region.id}"
    end
    target_key = Util::Ask.for_string("Type in key of experience to delete: ")
    target_experience = experiences.select{|e| e.key == target_key}.first
    if target_experience.nil?
      puts "Selected experience '#{target_key}' is invalid"
      exit(1)
    end

    puts "Deleting Experience with ID [#{target_experience.id}], Key [#{target_experience.key}], Region [#{target_experience.region.id}]"
    begin
      client.experiences.delete_by_key(org, target_experience.key)
      puts "Done"
    rescue Io::Flow::V0::HttpClient::ServerError => e
      if e.code == 422
        puts "Failed: #{e.message}"
      else
        raise e
      end
    end
  end

end
