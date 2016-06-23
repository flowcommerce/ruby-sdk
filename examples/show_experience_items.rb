module ShowExperienceItems

  def ShowExperienceItems.run(client, org)
    destination = client.experiences.get(org).map(&:country).first
    if destination.nil?
      destination = "CAN"
    end

    puts "Fetching items localized to %s" % destination
    
    client.experiences.get_items(org, :destination => destination).each do |i|
      puts i.inspect
    end
  end

end
