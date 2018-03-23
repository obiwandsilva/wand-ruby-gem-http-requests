require 'net/https'
require 'cgi'

# Connection allows the creation of an HTTP/HTTPS connection
#   that allows the issues of HTTP requests.
class HTTPConn
  attr_accessor :settings
  attr_reader :url

  def initialize(url, settings = {})
    @started = false
    @http = nil
    @url = url

    self.settings = {
      header: {},
      ssl: false,
      cert: "",
      read_timeout: 60
    }
    self.settings.merge!(settings)
  end

  def get(options = {})
    default = {
      end_point: "",
      header: {},
      query_str: {}
    }
    options = default.merge(options)
    url = query_str("#{@url}#{options[:end_point]}", options[:query_str])

    uri = URI(url)
    http = @started ? @http : get_http(uri)
    request = Net::HTTP::Get.new(uri.request_uri,
                                 settings[:header].merge(options[:header]))
    http.request(request)
  end

  def post(options = {})
    default = {
      end_point: "",
      header: {},
      body: nil
    }
    options = default.merge(options)
    uri = URI("#{@url}#{options[:end_point]}")

    http = @started ? @http : get_http(uri)
    request = Net::HTTP::Post.new(uri.request_uri,
                                  settings[:header].merge(options[:header]))
    http.request(request, options[:body])
  end

  def put(options = {})
    default = {
      end_point: "",
      header: {},
      body: nil
    }
    options = default.merge(options)
    uri = URI("#{@url}#{options[:end_point]}")

    http = @started ? @http : get_http(uri)
    request = Net::HTTP::Put.new(uri.request_uri,
                                  settings[:header].merge(options[:header]))
    http.request(request, options[:body])
  end

  def start(uri = nil)
    @started = true
    @http = uri.nil? ? get_http(URI(@url)) : get_http(URI(uri))
    @http.start
    yield
    @http.finish # Close connection after usage in 'yield'.
    @started = false
  end

  private

  def query_str(url, data)
    unless data.empty?
      first = data.keys[0]
      url = "#{url}?#{first}=#{data[first]}"

      data.each_key do |key|
        next if key == first
        url = "#{url}&#{key}=#{data[key]}"
      end
    end
    url
  end

  def get_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = settings[:read_timeout]

    if settings[:ssl]
      http.use_ssl = true
      if settings[:cert].empty?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cs_file = settings[:cert]
      end
    end
    http
  end
end
