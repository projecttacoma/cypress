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
    Rails.cache.fetch("#{cache_key}/measure") do
      FHIR::Bundle.new(measure_bundle_hash)
    end
  end

  def effective_period
    measure_resource.effectivePeriod
  end

  private

  def measure_resource
    Rails.cache.fetch("#{cache_key}/measure_resource") do
      measure.entry.find { |e| e.resource.resourceType == 'Measure' }.resource
    end
  end
end

class PatientBundle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  belongs_to :bundle, class_name: 'Bundle'

  field :patient_bundle_hash, type: Hash, default: {}

  def patient
    Rails.cache.fetch("#{cache_key}/patient") do
      FHIR::Bundle.new(patient_bundle_hash)
    end
  end

  def name
    patient_resource.name
  end

  private

  def patient_resource
    Rails.cache.fetch("#{cache_key}/patient_resource") do
      patient.entry.find { |e| e.resource.resourceType == 'Patient' }.resource
    end
  end
end
