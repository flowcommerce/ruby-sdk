module CreateItems

  def CreateItems.run(client, org)
    number_items = Util::Ask.for_positive_integer("How many items should we create?")
    
    currencies = ["USD"]
    categories = ["Apparel", "Accessories", "Mens", "Womens", "Belts", "Special"]

    count = 0
    number_items.times do |i|
      count += 1
      number = "sku-" + Time.now.strftime("%Y%m") + "-" + rand(10000).to_s
      puts " %s/%s. creating item %s/%s" % [count, number_items, org, number]

      client.items.put_by_number(org,
                                 number,
                                 ::Io::Flow::V0::Models::ItemForm.new(
                                   :number => number,
                                   :locale => "en_US",
                                   :name => "Flow Test Item #{number}",
                                   :description => "Only the finest fabric...",
                                   :currency => Util.pick_n(currencies, 1).first,
                                   :price => 100 + rand(120),
                                   :categories => Util.pick_n(categories, 2),
                                   :attributes => [
                                     { :key => "size", :value => "small" },
                                     { :key => "color", :value => "blue" }
                                   ],
                                   :dimensions => [
                                     {
                                       :type => "product",
                                       :depth => { :value => "1", :units => "foot" },
                                       :length => { :value => "18", :units => "inch" },
                                       :width => { :value => "36", :units => "inches" },
                                       :weight => { :value => "1.5", :units => "pounds" }
                                     }
                                   ],
                                   :images => [
                                     {
                                       :url => "http://lorempixel.com/200/400/fashion/",
                                       :tags => ["test"]
                                     }
                                   ]
                                 )
                                )
    end
  end

end
