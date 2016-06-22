module DeleteAllExperiences

  def DeleteAllExperiences.run(client, org)
    client.experiences.get(org).each do |exp|
      puts " - Deleting experience name[%s] key[%s] country[%s]" % [exp.name, exp.key, exp.country]
      client.experiences.delete_by_key(org, exp.key)
    end
  end

end
