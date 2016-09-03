module CreateAuthorization

  def CreateAuthorization.run(client, org)
    region_id = "can"

    card = client.cards.post(org,
                             ::Io::Flow::V0::Models::CardForm.new(
                               :number => "378282246310005",
                               :name => "Joe Smith",
                               :expiration_month => 1,
                               :expiration_year => Time.now.year + 1
                             )
                            )
    puts card.inspect
    
    auth = client.authorizations.post(org,
                                      ::Io::Flow::V0::Models::DirectAuthorizationForm.new(
                                        :token => card.token,
                                        :amount => 3122,
                                        :currency => "USD",
                                        :customer => {
                                          :name => {:first => "Joe", :last => "Smith"}
                                        }
                                      )
                                     )

    puts "Authorization Created: %s" % auth.inspect
  end

end
