module CreateExperience

  def CreateExperience.run(client, org)
    country = Util::Ask.for_string("Country code (e.g. CAN, AUS): ")
    
    exp = client.experiences.post(org,
                                  ::Io::Flow::Experience::V0::Models::ExperienceForm.new(
                                    :country => country,
                                    :name => country,
                                  )
                                 )

    puts "Experience Created: name[%s] key[%s] country[%s]" % [exp.name, exp.key, exp.country]
  end

end
