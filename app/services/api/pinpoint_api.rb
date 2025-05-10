module Api
  class PinpointApi
    require 'uri'
    require 'net/http'

    BASE_URL = URI('https://developers-test.pinpointhq.com/api/v1/applications/')
    ATTACHMENT_PARMAS = '?extra_fields[applications]=attachments'
    
    def self.get_application(id)
      url = URI("#{BASE_URL}#{id}#{ATTACHMENT_PARMAS}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/vnd.api+json'
      request["X-API-KEY"] = ENV['PINPOINT_API_KEY']
      response = http.request(request)
      JSON.parse(response.body)

      if response.code.to_i == 200
        Rails.logger.info "Fetched Pinpoint application, application ID: #{id}"
        return JSON.parse(response.body)
      else
        puts "Failed to fetch Pinpoint application: #{response.code.to_i}, Body: #{response.body}"
        return nil
      end
    end

    def self.add_comment(application_id, employee_id)
      url = URI("https://developers-test.pinpointhq.com/api/v1/comments")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["accept"] = 'application/vnd.api+json'
      request["content-type"] = 'application/vnd.api+json'
      request["X-API-KEY"] = ENV['PINPOINT_API_KEY']
      request.body = { data: {
          type: "comments",
          attributes: {
            body_text: "Record created with ID: #{employee_id}"
          },
          relationships: {
            commentable: {
              data: {
                type: "applications",
                id: application_id
              }
            }
          }
        }
      }.to_json

      response = http.request(request)
      
      if response.code.to_i == 201
        Rails.logger.info "Comment added to Pinpoint application, application ID: #{application_id}"
        return JSON.parse(response.body)
      else
        puts "Failed to add comment: #{response.code.to_i}"
        return nil
      end
    end
  end
end
