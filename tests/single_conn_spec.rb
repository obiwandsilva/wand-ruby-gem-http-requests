require 'json'
require_relative '../lib/single_conn'

describe "SingleConn" do
  describe "#init" do
    it "instantiate a new SingleConn object with default connection settings" do
      SingleConn.init("http://www.google.com")
      settings = SingleConn.conn_settings

      expect(settings[:header]).to eq({})
      expect(settings[:ssl]).to eq(false)
      expect(settings[:cert]).to eq("")
      expect(settings[:read_timeout]).to eq(60)
    end

    it "instantiate a new SingleConn object with preset connection settings" do
      settings = {
        :header => { "Accept" => "application/json" },
        :ssl => true,
        :read_timeout => 90
      }
      SingleConn.init("http://www.google.com", settings)

      set = SingleConn.conn_settings

      expect(set[:header]).to eq({ "Accept" => "application/json" })
      expect(set[:ssl]).to eq(true)
      expect(set[:cert]).to eq("")
      expect(set[:read_timeout]).to eq(90)
    end
  end

  describe "#get" do
    it "issues a http get request to the specified url" do
      SingleConn.init("https://www.googleapis.com", :ssl => true)
      res = SingleConn.get({
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
      SingleConn.init("https://viacep.com.br", :ssl => true)
      res = SingleConn.post({ :end_point => "/ws/01001000/json" })

      expect(res.code).to eq("200")
      expect(JSON.parse(res.body)["localidade"]).to eq("São Paulo")
    end
  end

  describe "#put" do
    it "issues a http put request to the specified url" do
      conn = SingleConn.init("https://www.mocky.io", :ssl => true)
      res = SingleConn.put({ :end_point => "/v2/5185415ba171ea3a00704eed" })

      expect(res.code).to eq("200")
      expect(JSON.parse(res.body)["hello"]).to eq("world")
    end
  end

  describe "#start" do
    it "allows the usage of the same connection to issue multiple requests" do
      SingleConn.init("https://viacep.com.br", :ssl => true)
      res_get = nil
      res_post = nil

      SingleConn.start do
        res_get = SingleConn.get({ :end_point => "/ws/01001000/json" })
        res_post = SingleConn.post({ :end_point => "/ws/01001000/json" })
      end

      expect(res_get.code).to eq("200")
      expect(res_post.code).to eq("200")
    end
  end
end