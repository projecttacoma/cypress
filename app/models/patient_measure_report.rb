class PatientMeasureReport
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :measure_report_hash, type: Hash
  field :care_gap_hash, type: Hash
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

  def care_gaps
    return [] unless care_gap_hash

    care_gap_resource = care_gaps_bundle.entry.find { |e| e.resource.resourceType == 'DetectedIssue' }&.resource
    return [] unless care_gap_resource

    gap_refs = care_gap_resource.evidence.map { |evidence| evidence.detail[0].reference.split('#')[1] }
    care_gap_array = []
    gap_refs.each do |gap_ref|
      care_gap_array << care_gap_resource.contained.find { |c| c.id == gap_ref }
    end
    care_gap_array
  end

  def valueset_name(oid)
    measure_valuesets.find { |mv| mv.resource.url == oid }.resource.name
  end

  private

  def measure_valuesets
    Rails.cache.fetch("#{cache_key}/measure_valuesets") do
      MeasureBundle.find(measure_id).measure.entry.select { |e| e.resource.resourceType == 'ValueSet' }
    end
  end

  def care_gaps_bundle
    Rails.cache.fetch("#{cache_key}/care_gaps") do
      FHIR::Bundle.new(care_gap_hash)
    end
  end

  def group_with_ipp?(group)
    group.population.any? { |pop| pop.count.positive? }
  end
end
