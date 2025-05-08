class CreateEmployeeService
  def initialize(webhook_data)
    @webhook_data = webhook_data
  end

  def create_employee
    Api::HibobApi(payload)
  end

  def get_application
    Api::PinpointApi.get_application(application_id)
  end

  def application_id
    @webhook_data['data']['application']['id']
  end

end