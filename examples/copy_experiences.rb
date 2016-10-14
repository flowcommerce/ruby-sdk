module CopyExperiences

  def CopyExperiences.run(client, org)
    target_key = Util::Ask.for_string("What is the organization key to which to copy experiences? ")
    
    client.experiences.get(org, :limit => 100).each_with_index do |exp, i|
      puts " %s. Experience %s" % [i, exp.key]

      region = client.regions.get_by_id(exp.region.id)
      puts "    - name: " + exp.name
      puts "    - region: " + exp.region.id
      puts "    - default_currency: " + exp.currency
      puts "    - countries: " + region.countries.join(", ")

      pricing = client.experiences.get_pricing_by_key(org, exp.key)
      puts "    - vat: #{pricing.vat.value}"
      puts "    - duty: #{pricing.duty.value}"
      if rounding = pricing.rounding
        puts "    - rounding:"
        puts "       - type: #{rounding.type.value}"
        puts "       - rounding_method: #{rounding.method.value}"
        puts "       - rounding_value: #{rounding.value.to_f}"
      else
        puts "    - rounding: none"
      end
    end

  end

end
