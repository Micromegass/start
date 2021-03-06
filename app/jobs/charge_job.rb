class ChargeJob < ActiveJob::Base
  queue_as :default

  def perform(charge_id)
    return unless Billing::Charge.exists?(charge_id)

    charge = Billing::Charge.find(charge_id)
    charge.update(attempts: charge.attempts + 1)

    begin
      create_customer(charge) unless customer_exists?(charge)
      perform_charge(charge) if customer_exists?(charge)
    rescue Net::ReadTimeout
      charge.update(status: :error, error_message: "Error en la conexión con la pasarela de pagos: Net::ReadTimeout")
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      charge.update(status: :error, error_message: "Error desconocido: \n\n\t#{e.message}", stack_trace: stack_trace)
    end
  end

  def customer_exists?(charge)
    charge.epayco_customer_id
  end

  def create_customer(charge)
    response = create_customer_request(charge)
    result = JSON.parse(response.body)
    logger.info result.inspect
    if !(result["success"] || result["status"])
      charge.update(status: :error, error_message: result["message"])
    else
      customer_id = result["data"]["customerId"]
      charge.update(epayco_customer_id: customer_id)
    end
  end

  def perform_charge(charge)
    response = create_charge_request(charge)

    result = JSON.parse(response.body)
    logger.info result.inspect
    if !result["success"]
      charge.update(status: :error, error_message: "#{result["message"]}. #{result["data"]["description"]}")
      # we don't send email when an error happen, usually the payment processor inform us
    else
      handle_valid_charge(charge, result)
    end
  end

  def create_customer_request(charge)
    HTTParty.post("https://api.secure.payco.co/payment/v1/customer/create",
        body: {
          public_key: ENV['EPAYCO_KEY'],
          token_card: charge.card_token,
          name: charge.customer_name,
          email: charge.customer_email,
          phone: charge.customer_mobile,
          default: true
        }.to_json,
        headers: { 'Content-Type' => 'application/json'})
  end

  def create_charge_request(charge)
    attrs = {
      public_key: ENV['EPAYCO_KEY'],
      token_card: charge.card_token,
      customer_id: charge.epayco_customer_id,
      doc_type: charge.customer_id_type,
      doc_number: charge.customer_id,
      name: charge.first_name,
      last_name: charge.last_name,
      email: charge.email,
      ip: charge.ip,
      bill: charge.uid,
      description: charge.description,
      value: "#{charge.amount}",
      tax: "#{charge.tax}",
      tax_base: "#{charge.amount - charge.tax}",
      currency: "COP",
      dues: "12"
    }

    attrs[:test] = "TRUE" unless Rails.env.production?

    HTTParty.post("https://api.secure.payco.co/payment/v1/charge/create",
        body: attrs.to_json,
        headers: { 'Content-Type' => 'application/json'})
  end

  def handle_valid_charge(charge, result)
    if result["data"]["estado"] == "Aceptada"
      charge.update(status: :paid, epayco_ref: result["data"]["ref_payco"])
    elsif result["data"]["estado"] == "Rechazada" || result["data"]["estado"] == "Fallida"
      charge.update(status: :rejected, error_message: result["data"]["respuesta"])
    end
  end
end
