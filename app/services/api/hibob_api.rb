module Api
  class HibobApi
    def initialize(payload)
      @payload = payload
    end
  end
end

require 'uri'
require 'net/http'

url = URI("https://api.hibob.com/v1/people")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Post.new(url)
request["accept"] = 'application/json'
request["content-type"] = 'application/json'
request["authorization"] = 'Basic U0VSVklDRS0xMTMzNDpLRkpnZE1jMnVPMW9qSWdFS0VnQVFucURLMnpqYThSRFNBTjdNdVBQ'
request.body = {
work: {
  site: "New York (Demo)",
  startDate: "2025-05-20"
},
firstName: "Chris",
surname: "Whitley",
email: "chris_whitley@hotmail.co.uk"
}.to_json

response = http.request(request)
puts response.read_body