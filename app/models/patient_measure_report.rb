class PatientMeasureReport
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :measure_report_hash, type: Hash
  field :patient_id, type: BSON::ObjectId
  field :measure_id, type: BSON::ObjectId

  def measure_report
    FHIR::MeasureReport.new(measure_report_hash)
  end
end
