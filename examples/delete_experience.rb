module DeleteExperience

  DELETE_SPECIFIC = "Delete a specific experience"
  DELETE_ALL = "Delete all but a set of experiences"
  
  def DeleteExperience.run(client, org)
    experiences = client.experiences.get(org, :limit => 100, :order => "position")

    puts "Available Experiences: "
    experiences.each do |experience|
      puts "  - ID: #{experience.id}, KEY: #{experience.key}, Region: #{experience.region.id}"
    end

    options = [DELETE_SPECIFIC, DELETE_ALL]

    selected = nil
    while selected.nil?
      message = "\nSelect how to delete:\n"
      options.each_with_index do |label, i|
        message << "  %s. %s\n" % [i+1, label]
      end.join("\n")
      prompt = Util::Ask.for_positive_integer(message)
      if prompt >= 1
        selected = options[prompt-1]
      end
    end
      
    if selected == DELETE_SPECIFIC
      exp = nil
      while exp.nil?
        key = Util::Ask.for_string("Type in key of experiences to delete: ")
        if exp = experiences.find { |exp| exp.key == key }
          to_remove = [exp]
        else
          puts "  ** No experience with key: #{key}"
        end
      end
      
    elsif selected == DELETE_ALL
      keep = Util::Ask.for_string("Type in key of experiences to KEEP (space separated): ").split
      to_remove = experiences.select { |exp| !keep.include?(exp.key) }
      
    else
      raise "ERROR - unknown task"
    end

    puts "\nAbout to delete the following experience(s):"
    to_remove.each do |experience|
      puts "  - ID: #{experience.id}, KEY: #{experience.key}, Region: #{experience.region.id}"
    end

    if Util::Ask.for_boolean("\nProceed?")
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
