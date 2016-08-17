module DeleteAllExperiences

  def DeleteAllExperiences.run(client, org)
    client.experiences.get(org).each do |exp|
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
