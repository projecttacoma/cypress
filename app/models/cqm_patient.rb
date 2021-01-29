class CQMPatient < FHIR::Patient

  attr_accessor :patient_resource
  attr_accessor :patient_bundle
  attr_accessor :id

  def initialize(patient_bundle)
    @id = patient_bundle.id
    @patient_bundle = FHIR::Bundle.new(patient_bundle.patient_bundle_hash)
    @patient_resource = @patient_bundle.entry.find{|e| e.resource.resourceType == "Patient"}.resource
  end

  def givenNames
    patient_resource.name[0].given
  end

  def familyName
    patient_resource.name[0].family
  end

  def patient_resource_id
    patient_resource.id
  end

  def birthDate
    patient_resource.birthDate
  end

  def gender
    patient_resource.gender
  end
end
