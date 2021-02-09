# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient_bundle, class: BundlePatientBundle do
    entry = Rails.root.join('test', 'fixtures', 'fhir', 'patient-bundle.json')
    transient do
      seq_id { 1 }
    end
    source_patient = JSON.parse(File.read(entry), max_nesting: 100)

    patient_bundle_hash { source_patient }
  end

  factory :vendor_patient_bundle, class: VendorPatientBundle do
    entry = Rails.root.join('test', 'fixtures', 'fhir', 'patient-bundle.json')
    transient do
      seq_id { 1 }
    end
    source_patient = JSON.parse(File.read(entry), max_nesting: 100)

    patient_bundle_hash { source_patient }

    after(:build) do |patient|
      create(:patient_measure_reports, measure_id: patient.bundle.fhir_measure_bundles.first.id, patient_id: patient.id)
    end
  end
end
