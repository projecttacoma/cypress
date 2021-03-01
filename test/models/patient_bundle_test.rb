require 'test_helper'

class PatientBundleTest < ActiveSupport::TestCase
  def setup
    @bundle = FactoryBot.create(:static_bundle)
  end

  def test_record_knows_bundle
    patient = PatientBundle.new(bundle: @bundle)
    patient.save
    assert_equal @bundle, patient.bundle, 'A record should know what bundle it is associated with if any'
  end

  def test_scoop_and_filter
    patient_bundle = @bundle.fhir_patient_bundles.first
    measure = @bundle.fhir_measure_bundles.first
    unfiltered_count = patient_bundle.patient.entry.size
    filtered_count = patient_bundle.scoop_and_filter(measure.id).size
    assert filtered_count < unfiltered_count, 'scoop_and_filter should result in fewer entries'
  end
end
