Rails.application.config.hl7_host = ENV['HL7_VALIDATION_SERVICE_HOST'] || 'localhost'
Rails.application.config.hl7_port = ENV['HL7_VALIDATION_SERVICE_PORT'] || '4567'
