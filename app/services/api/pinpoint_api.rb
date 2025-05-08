module Api
  class PinpointApi
    require 'uri'
    require 'net/http'

    BASE_URL = URI('https://developers-test.pinpointhq.com/api/v1/applications/')
    
    def self.get_application(id)
      url = URI("#{BASE_URL}#{id}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/vnd.api+json'
      request["X-API-KEY"] = ENV["PINPOINT_API_KEY"]
      response = http.request(request)
      puts "RESPONSE", response.read_body
    end
  end
end
