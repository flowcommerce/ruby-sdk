require 'time'

class LoggingHttpClient < ::Io::Flow::V0::HttpClient::DefaultHttpHandler

  def execute(request)
    original_open = client.open_timeout
    original_read = client.read_timeout

    start_time = Time.now.utc.round(10)
    puts "[%s] start %s %s" % [start_time.iso8601(6), request.method, request.path]

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
      puts "[%s] complete %s ms %s %s" % [end_time.iso8601(6), duration, request.method, request.path]
    end    
    
  end

end

  
