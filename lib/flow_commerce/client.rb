module FlowCommerce

  def FlowCommerce.client(token, opts = {})
    if token.empty?
      raise "ERROR: Token is required"
    end

    base_url = opts[:base_url].to_s.strip
    auth = Io::Flow::Catalog::V0::HttpClient::Authorization.basic(token)

    if base_url.empty?
      Io::Flow::Catalog::V0::Client.at_base_url(:authorization => auth)
    else
      Io::Flow::Catalog::V0::Client.new(base_url, :authorization => auth)
    end
  end


end
