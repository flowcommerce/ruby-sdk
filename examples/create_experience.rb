module CreateExperience

  def CreateExperience.run(client, org)
    region_id = "can"

    exp = client.experiences.post(org,
                                  ::Io::Flow::V0::Models::ExperienceForm.new(
                                    :region_id => region_id,
                                    :name => "canada",
                                    :language => "en" # Required as canada has en or fr
                                  )
                                 )

    puts "Experience Created: name[%s] key[%s] region[%s]" % [exp.name, exp.key, exp.region.id]
  end

end
