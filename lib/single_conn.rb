require_relative 'http_conn'

# SingleConn
module SingleConn
  extend self

  def init(url, settings = {})
    @conn = HTTPConn.new(url, settings)
  end

  def conn_settings
    @conn.settings
  end

  def get(options = {})
    @conn.get(options)
  end

  def post(options = {})
    @conn.post(options)
  end

  def put(options = {})
    @conn.put(options)
  end

  def delete(options = {})
    @conn.delete(options)
  end

  def start(uri = nil)
    uri = uri.nil? ? URI(@conn.url) : URI(uri)
    @conn.start(uri) { yield }
  end
end
