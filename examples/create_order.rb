require 'SecureRandom'

module CreateOrder

  # Creates an order given an experience key and a number of orders to create
  def CreateOrder.run(client, org)
    n = Util::Ask.for_positive_integer("Enter number of orders to create: ")

    experiences = client.experiences.get(org, :limit => 100, :order => "position")

    puts "Available Experiences: "
    experiences.each do |experience|
      puts "  - ID: #{experience.id}, KEY: #{experience.key}, Region: #{experience.region.id}"
    end

    experience_key = Util::Ask.for_string("Type in experience key to use: ")
    experience = experiences.select{|e| e.key == experience_key}.first
    if experience.nil?
      puts "Invalid experience - exiting"
      exit(1)
    end

    # credit card to use
    card = client.cards.post(
      org,
      ::Io::Flow::V0::Models::CardForm.new(
        :number => "4111111111111111",
        :name => "Joe Smith",
        :expiration_month => 1,
        :expiration_year => Time.now.year + 1,
        :cvv => "737"
      )
    )

    # just use whatever the first item is
    item = client.items.get(org, :limit => 1, :offset => 0).first

    # create the number of orders we want
    (1..n).each do |i|
      # generate a random number
      number = "example-#{SecureRandom.uuid}"

      # create the order
      order = client.orders.put_by_number(
        org,
        number,
        ::Io::Flow::V0::Models::OrderPutForm.new(
          :customer => {
            :name => {:first => "John", :last => "Smith"},
            :email => "john@smith.com"
          },
          :items => [
            { :number => item.number, :quantity => 1 }
          ],
          :destination => {
            :streets => [ "123 Sesame Street" ],
            :city => "",
            :province => "",
            :postal => "1234",
            :country => experience.country,
            :contact => {
              :name => { :first => "John", :last => "Smith" },
              :email => "john@smith.com"
            }
          }
        ),
        :delivered_duty => "paid",
        :experience => experience.key
      )

      auth = client.authorizations.post(
        org,
        ::Io::Flow::V0::Models::MerchantOfRecordAuthorizationForm.new(
          :token => card.token,
          :order_number => order.number,
          :amount => order.total.amount,
          :currency => order.total.currency,
          :customer => {
            :name => {:first => "Joe", :last => "Smith"}
          }
        )
      )

      capture = client.captures.post(
        org,
        ::Io::Flow::V0::Models::CaptureForm.new(
          :authorization_id => auth.id
        )
      )

      puts "Created order: #{order.id}, number #{order.number}, auth: #{auth.id}, capture: #{capture.id}"
    end
  end

end
