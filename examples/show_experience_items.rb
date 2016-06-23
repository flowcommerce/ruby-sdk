module ShowExperienceItems

  def ShowExperienceItems.run(client, org)
    destination = client.experiences.get(org).map(&:country).first
    if destination.nil?
      destination = "CAN"
    end

    puts "Fetching items localized to %s" % destination
    
    client.experiences.get_items(org, :destination => destination, :limit => 10, :offset => 0).each_with_index do |item, i|
      puts "%s. %s:" % [i+i, item.number]
      item.local.prices.each do |price|
        puts "  - %s: %s" % [price.key, price.label]
      end
    end
  end

end
