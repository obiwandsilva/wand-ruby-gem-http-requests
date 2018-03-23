require 'json'
require_relative '../lib/http_conn'

describe "HTTPConn" do
  describe "#initialize" do
    it "instantiate a new HTTPConn object with default connection settings" do
      conn = HTTPConn.new("http://www.google.com")

      expect(conn.settings[:header]).to eq({})
      expect(conn.settings[:ssl]).to eq(false)
      expect(conn.settings[:cert]).to eq("")
      expect(conn.settings[:read_timeout]).to eq(60)
    end

    it "instantiate a new HTTPConn object with preset connection settings" do
      settings = {
        :header => { "Accept" => "application/json" },
        :ssl => true,
        :read_timeout => 90
      }
      conn = HTTPConn.new("https://www.google.com", settings)

      expect(conn.settings[:header]).to eq({ "Accept" => "application/json" })
      expect(conn.settings[:ssl]).to eq(true)
      expect(conn.settings[:cert]).to eq("")
      expect(conn.settings[:read_timeout]).to eq(90)
    end
  end

  describe "#get" do
    it "issues a http get request to the specified url" do
      conn = HTTPConn.new("https://www.googleapis.com", :ssl => true)
      res = conn.get({
        :end_point => "/customsearch/v1",
        :query_str => {
          "q" => "silvawand"
        }
      })

      expect(res.code).to eq("403")
      expect(JSON.parse(res.body)["error"]["code"]).to eq(403)
    end
  end

  describe "#post" do
    it "issues a http post request to the specified url" do
      conn = HTTPConn.new("https://viacep.com.br", :ssl => true)
      res = conn.post({ :end_point => "/ws/01001000/json" })

      expect(res.code).to eq("200")
      expect(JSON.parse(res.body)["localidade"]).to eq("São Paulo")
    end
  end

  describe "#start" do
    it "allows the usage of the same connection to issue multiple requests" do
      conn = HTTPConn.new("https://viacep.com.br", :ssl => true)
      res_get = nil
      res_post = nil

      conn.start do
        res_get = conn.get({ :end_point => "/ws/01001000/json" })
        res_post = conn.post({ :end_point => "/ws/01001000/json" })
      end

      expect(res_get.code).to eq("200")
      expect(res_post.code).to eq("200")
    end
  end
end