require 'SecureRandom'

module CreateOrder

  def CreateOrder.run(client, org)
    item = client.items.get(org, :limit => 10, :offset => 0).first

    number = SecureRandom.uuid

    order = client.orders.put_by_number(
      org,
      number,
      ::Io::Flow::V0::Models::OrderPutForm.new(
        :customer => {
          :name => {:first => "Paolo", :last => "Lim"},
          :email => "paolo@flow.io"
        },
        :items => [
          { :number => item.number, :quantity => 1 }
        ],
        :destination => {
          :streets => [ "123 Yonge Street" ],
          :city => "Toronto",
          :province => "ON",
          :postal => "M5C 1W4",
          :country => "CAN",
          :contact => {
            :name => { :first => "Paolo", :last => "Lim" },
            :email => "paolo@flow.io"
          }
        }
      ),
      :delivered_duty => "paid",
      :experience => "canada"
    )

    puts order.inspect
  end

end
