require 'logger'
require 'time'

class LoggingHttpClient < ::Io::Flow::V0::HttpClient::DefaultHttpHandler

  def initialize(base_uri, path)
    super(base_uri)
    @logger = Logger.new(path)
  end

  def execute(request)
    original_open = client.open_timeout
    original_read = client.read_timeout

    start_time = Time.now.utc.round(10)
    @logger.info "start %s %s" % [request.method, request.path]

    if request.path.start_with?("/organizations")
      # Contrived example to show how client settings can be adjusted
      client.open_timeout = 60
      client.read_timeout = 60
    end

    begin
      super
    ensure
      client.open_timeout = original_open
      client.read_timeout = original_read

      end_time = Time.now.utc.round(10)
      duration = ((end_time - start_time)*1000).round(0)
      @logger.info "complete %s %s %s ms" % [request.method, request.path, duration]
    end    
    
  end

end

  
