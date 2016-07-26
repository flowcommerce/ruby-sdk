module ShowExperienceItems

  def ShowExperienceItems.run(client, org)
    country = "can"

    puts "Fetching items localized to %s" % country
    
    client.experiences.get_items(org, :destination => country, :limit => 10, :offset => 0).each do |item|
      puts "%s:" % item.number
      puts "  - base price: %s" % item.price.label
      item.local.prices.each do |price|
        puts "  - %s: %s" % [price.key, price.label]
      end
    end
  end

end
