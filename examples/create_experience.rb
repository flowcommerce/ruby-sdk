module CreateExperience

  def CreateExperience.run(catalog_client, experience_client, org)
    country = Util::Ask.for_string("Country code (e.g. CAN, AUS): ")

    puts "CREATING subcatalog"

    subcatalog = catalog_client.subcatalogs.post(
      org,
      ::Io::Flow::Catalog::V0::Models::SubcatalogForm.new(:country => country)
    )

    puts "subcatalog: #{subcatalog.inspect}"
        
    exp = experience_client.experiences.post(org,
                                             ::Io::Flow::Experience::V0::Models::ExperienceForm.new(
                                               :country => country,
                                               :name => country,
                                               :subcatalog_id => subcatalog.id
                                             )
                                            )

    puts "Experience Created: name[%s] key[%s] country[%s]" % [exp.name, exp.key, exp.country]
  end

end
