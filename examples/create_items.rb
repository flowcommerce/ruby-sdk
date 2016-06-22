module CreateItems

  def CreateItems.run(client, org)
    number_items = Util::Ask.for_positive_integer("How many items should we create?")
    
    currencies = ["USD", "CAD", "AUD", "GBP"]
    categories = ["Apparel", "Accessories", "Mens", "Womens", "Belts", "Special"]

    count = 0
    number_items.times do |i|
      count += 1
      number = "sku-" + Time.now.strftime("%Y%m") + "-" + rand(10000).to_s
      puts " %s/%s. creating item %s/%s" % [count, number_items, org, number]

      client.items.put_by_number(org,
                                 number,
                                 ::Io::Flow::Catalog::V0::Models::ItemForm.new(
                                   :number => number,
                                   :locale => "en_US",
                                   :name => "Flow Test Item #{number}",
                                   :currency => Util.pick_n(currencies, 1).first,
                                   :price => 100 + rand(120),
                                   :categories => Util.pick_n(categories, 2),
                                 )
                                )
    end
  end

end
