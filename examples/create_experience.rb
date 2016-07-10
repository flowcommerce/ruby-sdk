module CreateExperience

  def CreateExperience.run(client, org)
    country = "CAN"

    subcatalog = client.subcatalogs.post(
      org,
      ::Io::Flow::V0::Models::SubcatalogForm.new(:country => country)
    )

    exp = client.experiences.post(org,
                                  ::Io::Flow::V0::Models::ExperienceForm.new(
                                    :country => country,
                                    :name => country,
                                    :subcatalog_id => subcatalog.id
                                  )
                                 )

    puts "Experience Created: name[%s] key[%s] country[%s]" % [exp.name, exp.key, exp.country]
  end

end
