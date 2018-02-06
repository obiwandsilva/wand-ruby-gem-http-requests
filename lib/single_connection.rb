require_relative 'connection'

module SingleConnection
  extend self

  def init(url, settings = {})
    @connection = Connection.new(url, settings)
  end

  def get_conn_settings
    @connection.settings
  end

  def get(options = {})
    @connection.get(options)
  end

  def post(options = {})
    @connection.post(options)
  end

  def start(uri = nil)
    arg = uri.nil? ? URI(@connection.url) : URI(uri)
    @connection.start(arg) { |connection| yield }
  end
end