module DeleteAllExperiences

  def DeleteAllExperiences.run(client, org)
    confirmation = Util::Ask.for_string("Type in name of org to confirm: ")
    if confirmation != org
      puts "Invalid entry - existing"
      exit(1)
    end

    offset = 0
    limit = 100
    experiences = client.experiences.get(org, :limit => limit, :offset => offset, :order => "position")
    if experiences.size > 0
      offset = offset + limit
      experiences << client.experiences.get(org, :limit => limit, :offset => offset, :order => "position")
    end
    experiences.flatten!

    experiences.each do |exp|
      puts " - Deleting experience name[%s] key[%s] region[%s]" % [exp.name, exp.key, exp.region.id]
      begin
        client.experiences.delete_by_key(org, exp.key)
      rescue Io::Flow::V0::HttpClient::ServerError => e
        if e.code == 422
          puts "   - Failed: #{e.message}"
        else
          raise e
        end
      end
    end
  end

end
