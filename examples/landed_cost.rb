module LandedCost

  def LandedCost.run(client, org)
    destination = Util::Ask.for_string("Destination country [Default 'CAN']: ", :default => "CAN")

    item_numbers = ARGV
    if item_numbers.empty?
      item_numbers = Util::Ask.for_string("Enter item numbers (space separated): ").split
    end

    form = ::Io::Flow::V0::Models::HarmonizedLandedCostForm.new(
      :address => { :country => destination },
      :item_numbers => item_numbers
    )
    
    puts "Computing landed cost to %s for items %s" % [destination, item_numbers.join(", ")]
    client.harmonized_landed_costs.post(org, form).items.each do |result|
      puts " - %s: duty[%s] %s[%s]" % [result.item.number, Util.pct(result.duty.rate), result.tax.name, Util.pct(result.tax.rate)]
    end
  end

end
