class CreateEmployeeService
  require 'open-uri'

  def initialize(webhook_data)
    @webhook_data = webhook_data
    @applicant_data = nil
  end

  def create_employee
    response = Api::HibobApi.create_employee(payload)
    employee_id = get_employee_id(response)
    upload_resume(employee_id, applicant_resume)
    Api::PinpointApi.add_comment(application_id, employee_id)
  end

  def upload_resume(employee_id, applicant_resume)
    Api::HibobApi.upload_resume(employee_id, applicant_resume)
  end

  def get_application
    @appplicant_data ||= Api::PinpointApi.get_application(application_id)
  end

  def application_id
    @webhook_data['data']['application']['id']
  end

  def payload
    applicant_data = get_application
    {
      work: {
        site: "New York (Demo)",
        startDate: 1.month.from_now.to_date.iso8601
      },
      firstName: applicant_data['data']['attributes']['first_name'],
      surname: applicant_data['data']['attributes']['last_name'],
      email: applicant_data['data']['attributes']['email']
    }.to_json
  end

  def get_employee_id(response)
    response['id']
  end

  def applicant_resume
    applicant_data = get_application
    attachments = applicant_data['data']['attributes']['attachments']
    url = attachments.find { |att| att["context"] == "pdf_cv" }&.dig("url")
    download_resume(url)
  end
  
  def download_resume(url)
    file = Tempfile.new(['resume', '.pdf'])
    file.binmode
    file.write URI.open(url).read
    file.rewind
    Rails.logger.info "Saved temp file at: #{file.path} (#{file.size} bytes)"
    file
  end
end