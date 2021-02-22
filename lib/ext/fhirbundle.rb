require_relative 'bundle.rb'

class MeasureBundle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  belongs_to :bundle, class_name: 'Bundle'

  field :measure_bundle_hash, type: Hash, default: {}

  delegate :name, to: :measure_resource
  delegate :version, to: :measure_resource

  def measure
    FHIR::Bundle.new(measure_bundle_hash)
  end

  def effective_period
    measure_resource.effectivePeriod
  end

  def measure_scoring
    measure_resource.scoring.coding[0].code
  end

  private

  def measure_resource
    # find actual patient resource (TODO: cache?)
    measure.entry.find { |e| e.resource.resourceType == 'Measure' }.resource
  end
end

class PatientBundle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  belongs_to :bundle, class_name: 'Bundle'

  field :patient_bundle_hash, type: Hash, default: {}
  field :correlation_id, type: BSON::ObjectId
  field :validation_results, type: Hash, default: {}

  def patient
    FHIR::Bundle.new(patient_bundle_hash)
  end

  # TODO: rename given_names
  def givenNames
    patient_resource.name[0].given
  end

  # TODO: rename family_name
  def familyName
    patient_resource.name[0].family
  end

  def patient_fhir_id
    patient_resource.id
  end

  # TODO: rename birthdate
  def birthDate
    patient_resource.birthDate
  end

  def gender
    patient_resource.gender
  end

  def retrieve_entries(resource_urls)
    patient.entry.select { |e| resource_urls.include?("#{e.resource.resourceType}/#{e.resource.id}") }
  end

  def validate(validator)
    patient.entry.each do |entry|
      resource = entry.resource
      profile_url = resource&.meta&.profile&.first
      validation_results[hexkey_for_entry(entry)] = validator.validate(resource, profile_url)
    end
    save
  end

  def hexkey_for_entry(entry)
    Digest::SHA2.hexdigest("#{entry.resource.resourceType} #{entry.resource.resourceType}")
  end

  def validation_result_for_entry(entry)
    validation_results[hexkey_for_entry(entry)] || { errors: [], warnings: [], information: [] }
  end

  def destroy
    PatientMeasureReport.where(patient_id: id).destroy_all
    delete
  end

  private

  def patient_resource
    # find actual patient resource
    patient.entry.find { |e| e.resource.resourceType == 'Patient' }.resource
  end
end

class BundlePatientBundle < PatientBundle; end
class VendorPatientBundle < PatientBundle; end
