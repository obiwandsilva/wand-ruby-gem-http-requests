require 'net/https'
require 'cgi'

class Connection
  attr_accessor :settings
  attr_reader :url

  def initialize(url, settings = {})
    @started = false
    @http = nil
    @url = url

    @settings = {
      :header => {},
      :ssl => false,
      :cert => "",
      :read_timeout => 60
    }
    @settings.merge!(settings)
  end

  def get(options = {})
    default = {
      :end_point => "",
      :header => {},
      :query_str => {}
    }
    options = default.merge(options)

    url = "#{@url}#{options[:end_point]}"

    unless options[:query_str].empty?
      first = options[:query_str].keys[0]
      url = "#{url}?#{first}=#{options[:query_str][first]}"

      options[:query_str].each_key do |key|
        next if key == first
        url = "#{url}&#{key}=#{options[:query_str][key]}"
      end
    end

    uri = URI(url)

    http = @started ? @http : get_http(uri)
    request = Net::HTTP::Get.new(uri.request_uri, @settings[:header].merge(options[:header]))
    http.request(request)
  end

  def post(options = {})
    default = {
      :end_point => "",
      :header => {},
      :body => nil
    }
    options = default.merge(options)
    uri = URI("#{@url}#{options[:end_point]}")

    http = @started ? @http : get_http(uri)
    request = Net::HTTP::Post.new(uri.request_uri, @settings[:header].merge(options[:header]))    
    http.request(request, options[:body])
  end

  def start(uri = nil)
    @started = true
    @http = uri.nil? ? get_http(URI(@url)) : get_http(URI(uri))
    @http.start
    yield
    @http.finish # Close connection after usage
    @started = false
  end

  private

  def get_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = @settings[:read_timeout]

    if @settings[:ssl]
      http.use_ssl = true
      if @settings[:cert].empty?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cs_file = @settings[:cert]
      end
    end

    return http
  end
end