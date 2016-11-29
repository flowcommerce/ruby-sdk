module DeleteExperience

  def DeleteExperience.run(client, org)
    experiences = client.experiences.get(org, :limit => 100, :order => "position")

    puts "Available Experiences: "
    experiences.each do |experience|
      puts "  - ID: #{experience.id}, KEY: #{experience.key}, Region: #{experience.region.id}"
    end

    keep = Util::Ask.for_string("Type in key of experiences to KEEP (space separated): ").split

    to_remove = experiences.select { |exp| !keep.include?(exp.key) }
    puts "About to delete the following experiences:"
    to_remove.each do |experience|
      puts "  - ID: #{experience.id}, KEY: #{experience.key}, Region: #{experience.region.id}"
    end

    if Util::Ask.for_boolean("Proceed? y/n")
      to_remove.each do |experience|
        print "  - Deleting #{experience.key}... "
        begin
          client.experiences.delete_by_key(org, experience.key)
          puts "done"
        rescue Io::Flow::V0::HttpClient::ServerError => e
          if e.code == 422
            puts "Failed: #{e.message}"
          else
            raise e
          end
        end
      end
    end
  end

end
