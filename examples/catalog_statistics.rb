module CatalogStatistics

  def CatalogStatistics.run(client, org)
    stats = client.catalogs.get_catalog_and_statistics(org)
    puts "Catalog statistics:"
    puts " - Number items: #{stats.items}"
    puts " - Number unique categories: #{stats.categories}"
  end

end
