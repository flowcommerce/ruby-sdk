require 'logger'
require 'time'

class LoggingHttpHandler < ::Io::Flow::V0::HttpClient::DefaultHttpHandler

  def initialize(logfile_path)
    @logger = Logger.new(logfile_path)
  end

  def instance(base_uri, path)
    LoggingHttpHandlerInstance.new(base_uri, @logger, path)
  end

end

class LoggingHttpHandlerInstance < ::Io::Flow::V0::HttpClient::DefaultHttpHandlerInstance

  def initialize(base_uri, logger, path)
    super(base_uri)
    @logger = logger

    if path.start_with?("/organizations")    
      # Contrived example to show how client settings can be adjusted
      client.open_timeout = 60
      client.read_timeout = 60
    end
  end

  def execute(request)
    start_time = Time.now.utc.round(10)
    @logger.info "start %s %s" % [request.method, request.path]

    begin
      super
    ensure
      end_time = Time.now.utc.round(10)
      duration = ((end_time - start_time)*1000).round(0)
      @logger.info "complete %s %s %s ms" % [request.method, request.path, duration]
    end    
    
  end

end

  
