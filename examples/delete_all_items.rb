module DeleteAllItems

  def DeleteAllItems.run(client, org)
    stats = client.catalogs.get_catalog_and_statistics(org)
    puts "Catalog statistics:"
    puts " - Number items: #{stats.items}"
    puts " - Number unique categories: #{stats.categories}"

    number_to_delete = Util::Ask.for_positive_integer("How many items would you like to delete?:")

    number_deleted = 0
    while true
      remaining = number_to_delete - number_deleted

      limit = if remaining > 100
        100
      else
        remaining
      end

      puts "Deleting up to #{number_to_delete} items. Fetching next #{limit} items"
      
      items = client.items.get(org, :limit => limit)
      items.each do |item|
        puts " - %s/%s Deleting %s/%s" % [number_deleted + 1, number_to_delete, org, item.number]
        client.items.delete_by_number(org, item.number)
        number_deleted += 1
      end

      if items.empty? || number_to_delete <= number_deleted
        puts ""
        puts "Deleted: %s" % number_deleted
        break
      end
      puts ""
    end
  end

end
