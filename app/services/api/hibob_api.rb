module Api
  class HibobApi
    require 'uri'
    require 'net/http'
    require 'base64'
    require 'faraday'
    require 'json'
    require 'multipart/post'

    def self.create_employee(payload)
      url = URI("https://api.hibob.com/v1/people")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["accept"] = 'application/json'
      request["content-type"] = 'application/json'
      credentials = Base64.strict_encode64("#{ENV["HIBOB_SERVICE_ID"]}:#{ENV["HIBOB_SERVICE_USER_TOKEN"]}")
      request["authorization"] = "Basic #{credentials}"
      request.body = payload
      response = http.request(request)

      if response.status == 200
        Rails.logger.info "Employee Created in HiBob at #{Time.current}"
        return JSON.parse(response.body)
      else
        Rails.logger.info "Failed to create employee: #{response.status}, Body: #{response.body}"
        return nil
      end

      

      JSON.parse(response.body)
    end

    def self.upload_resume(employee_id, resume)
      puts "UPLOADING RESUME"
      url = "https://api.hibob.com/v1/docs/people/#{employee_id}/shared/upload"

      conn = Faraday.new(url: url) do |faraday|
        faraday.adapter Faraday.default_adapter 
        faraday.request :multipart                     
      end

      credentials = Base64.strict_encode64("#{ENV["HIBOB_SERVICE_ID"]}:#{ENV["HIBOB_SERVICE_USER_TOKEN"]}")

      file_io = UploadIO.new(resume.path, 'application/pdf', File.basename(resume.path))

      response = conn.post do |req|
        req.headers['Authorization'] = "Basic #{credentials}"
        req.headers['Accept'] = 'application/json'
        req.body = { 'file' => file_io }
      end

      puts "UPLOAD Response status: #{response.status}"
      puts "UPLOAD Response body: #{response.body}"

      if response.status == 200
        Rails.logger.info "Resume uploaded to HiBob, HiBob ID: #{employee_id}"
        return JSON.parse(response.body)
      else
        Rails.logger.info "Failed to upload resume: #{response.status}, Body: #{response.body}"
        return nil
      end
    end
  end
end