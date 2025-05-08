class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def pinpoint
      webhook_data = JSON.parse(request.body.read)
      logger.info "Received webhook: #{webhook_data}"
      if webhook_data['event'] == 'application_hired'
        CreateEmployeeService.new(webhook_data).get_application
        # puts "CORRECT EVENT RECEIVED"
      else
        puts "INCORRECT EVENT RECEIVED"
      end
      render json: { message: "Webhook received successfully", status: "success", data: (webhook_data)}
  end
end