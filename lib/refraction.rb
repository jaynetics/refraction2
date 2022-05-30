require 'rack'
require_relative 'refraction/version'

class Refraction
  class Request < Rack::Request
    attr_reader :action, :status, :message

    # backward compatibility: support URI::HTTP component names
    def method; request_method; end
    def query;  query_string;   end

    ### actions

    def set(options)
      if options.is_a?(String)
        @re_location = options
      else
        @re_scheme = options[:protocol] if options[:protocol] # :protocol is alias for :scheme
        @re_scheme = options[:scheme]   if options[:scheme]
        @re_host   = options[:host]     if options[:host]
        @re_port   = options[:port]     if options[:port]
        @re_path   = options[:path]     if options[:path]
        @re_query  = options[:query]    if options[:query]
      end
    end

    def rewrite!(options)
      @action = :rewrite
      set(options)
    end

    def permanent!(options)
      @action = :permanent
      @status = 301
      set(options)
      @message = "moved to #{@uri}"
    end

    def found!(options)
      @action = :found
      @status = 302
      set(options)
      @message = "moved to #{@uri}"
    end

    def respond!(status, headers, content)
      @action = :respond
      @status = status
      @headers = headers
      @message = content
    end

    ### response

    def response
      headers = @headers || { 'Location' => location, 'Content-Type' => 'text/plain' }
      headers['Content-Length'] = message.length.to_s
      [status, headers, [message]]
    end

    def location
      @re_location || url
    end

    # use original request's values when not set explicitly
    def scheme;       @re_scheme || super; end
    def host;         @re_host   || super; end
    def path;         @re_path   || super; end
    def query_string; @re_query  || super; end

    # changing the scheme or host means use default port instead of port in original request
    def port
      @re_port || ((@re_scheme || @re_host) && DEFAULT_PORTS[scheme]) || super
    end

    def http_host
      port ? "#{host}:#{port}" : host
    end
  end ### class Request

  def self.configure(&block)
    @rules = block
  end

  def self.rules
    @rules
  end

  def initialize(app)
    @app = app
  end

  def rules
    self.class.rules
  end

  def call(env)
    return @app.call(env) unless rules

    request = Request.new(env)
    rules.call(request)

    case request.action
    when :permanent, :found, :respond
      request.response
    when :rewrite
      env["rack.url_scheme"]  = request.scheme
      env["HTTP_HOST"]        = request.http_host
      env["SERVER_NAME"]      = request.host
      env["HTTP_PORT"]        = request.port if request.port
      env["PATH_INFO"]        = request.path
      env["QUERY_STRING"]     = request.query
      env["REQUEST_URI"]      = request.fullpath
      @app.call(env)
    else
      @app.call(env)
    end
  end
end
