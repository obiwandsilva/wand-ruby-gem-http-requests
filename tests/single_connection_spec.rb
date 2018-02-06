require 'json'
require_relative '../lib/single_connection'

describe "SingleConnection" do
  describe "#init" do
    it "instantiate a new SingleConnection object with default connection settings" do
      SingleConnection.init("http://www.google.com")
      settings = SingleConnection.get_conn_settings

      expect(settings[:header]).to eq({})
      expect(settings[:ssl]).to eq(false)
      expect(settings[:cert]).to eq("")
      expect(settings[:read_timeout]).to eq(60)
    end

    it "instantiate a new SingleConnection object with preset connection settings" do
      settings = {
        :header => { "Accept" => "application/json" },
        :ssl => true,
        :read_timeout => 90
      }
      SingleConnection.init("http://www.google.com", settings)

      set = SingleConnection.get_conn_settings

      expect(set[:header]).to eq({ "Accept" => "application/json" })
      expect(set[:ssl]).to eq(true)
      expect(set[:cert]).to eq("")
      expect(set[:read_timeout]).to eq(90)
    end
  end

  describe "#get" do
    it "issues a http get request to the specified url" do
      SingleConnection.init("https://www.googleapis.com", :ssl => true)
      res = SingleConnection.get({
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
      SingleConnection.init("https://viacep.com.br", :ssl => true)
      res = SingleConnection.post({ :end_point => "/ws/01001000/json" })

      expect(res.code).to eq("200")
      expect(JSON.parse(res.body)["localidade"]).to eq("São Paulo")
    end
  end

  describe "#start" do
    it "allows the usage of the same connection to issue multiple requests" do
      SingleConnection.init("https://viacep.com.br", :ssl => true)
      res_get = nil
      res_post = nil

      SingleConnection.start do
        res_get = SingleConnection.get({ :end_point => "/ws/01001000/json" })
        res_post = SingleConnection.post({ :end_point => "/ws/01001000/json" })
      end

      expect(res_get.code).to eq("200")
      expect(res_post.code).to eq("200")
    end
  end
end