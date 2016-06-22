module ShowExperienceItems

  def ShowExperienceItems.run(client, org)
    destination = Util::Ask.for_string("Destination country code (e.g. CAN, AUS): ")

    # Note: Can also filter by number, ip, etc.
    items = client.experiences.get_items(org,
                                         :destination => destination
                                        )
    items.foreach do |i|
      puts i.inspect
    end
  end

end
