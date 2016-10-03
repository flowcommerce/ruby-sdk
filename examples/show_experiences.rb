require 'csv'

module ShowExperiences

  CREATE_CSV = true
  
  # Show information about each experience. Also creates a CSV file
  def ShowExperiences.run(client, org)
    csv_file = CREATE_CSV ? "/tmp/ruby-sdk-experiences.#{Process.pid}.csv" : nil

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

      if CREATE_CSV
        CSV.open(csv_file, "ab") do |csv|
          if i == 0
            csv << %w(id key name region_id default_currency countries pricing_vat pricing_duty pricing_rounding_type pricing_rounding_method pricing_rounding_value)
          end
          data = [exp.id, exp.key, exp.name, exp.region.id, exp.currency, region.countries.join(" "), pricing.vat.value, pricing.duty.value]
          if rounding
            data << rounding.type.value
            data << rounding.method.value
            data << rounding.value.to_f
          else
            data << ""
            data << ""
            data << ""
          end
          csv << data
        end
      end
    end

    if CREATE_CSV
      puts "CSV output available at %s" % csv_file
    end
  end

end
