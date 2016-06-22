module DeleteAllItems

  def DeleteAllItems.run(client, org)
    num_deleted = 0
    while true
      puts "Fetching 100 items from master catalog to delete"
      items = client.items.get(org, :limit => 100)
      items.each do |item|
        puts " - Deleting %s/%s" % [org, item.number]
        client.items.delete_by_number(org, item.number)
        num_deleted += 1
      end

      if items.empty?
        puts ""
        puts "Deleted: {num_deleted}"
        break
      end
      puts ""
    end
  end

end
