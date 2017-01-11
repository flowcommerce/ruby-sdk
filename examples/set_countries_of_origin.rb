module SetCountriesOfOrigin

  def SetCountriesOfOrigin.run(client, org)
    coo = Util::Ask.for_string("Countries of origin (Space separated iso3 codes): ").upcase

    count = 1
    offset = 0
    limit = 100
    number_updated = 0
    while true
      items = client.items.get(org, :limit => limit, :offset => offset)

      items.each do |item|
        existing = item.attributes['countries_of_origin']
        if existing != coo
          print "#{count}. item[#{item.number}] updating countries of origin from '#{existing}' to '#{coo}'... "
          count += 1

          item.attributes[:countries_of_origin] = coo
          map = item.to_hash
          map.delete(:price)
          map[:currency] = item.price.currency
          map[:price] = item.price.amount
          
          form = ::Io::Flow::V0::Models::ItemForm.new(map)
          client.items.put_by_number(org, item.number, form)
          puts "Done"
        end
      end
      
      if items.size < limit
        break
      else
        offset += limit
      end      
    end
  end

end
