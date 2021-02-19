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

  def evaluated_resources
    measure_report.evaluatedResource.map(&:reference)
  end

  def in_ipp?
    measure_report.group.any? { |mrg| group_with_ipp?(mrg) }
  end

  private

  def group_with_ipp?(group)
    group.population.any? { |pop| pop.count.positive? }
  end
end
