module ShowItems

  def ShowItems.run(client, org)
    client.items.get(org, :limit => 10, :offset => 0).each_with_index do |item, i|
      puts "%s. %s" % [i, item.number]
    end
  end

end
