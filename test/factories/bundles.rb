FactoryBot.define do
  factory :bundle, class: Bundle do
    sequence(:name) { |i| "Bundle Name #{i}" }
    sequence(:version) { |i| "#{2050 + i}.0.0" }
    sequence(:title) { |i| "Bundle Name #{i}" }

    after(:build) do |bundle|
      create(:patient_bundle, seq_id: 1, bundle: bundle)
      create(:measure_bundle, seq_id: 1, bundle: bundle)
    end

    # Includes measure calculations
    factory :static_bundle do
      active { true }
      done_importing { true }
      name { 'Static Bundle' }
      title { 'Static Bundle' }
      version { '2021.0.0' }
      measure_period_start { 1_483_228_800 } # Jan 1 2017
      effective_date { 1_514_764_799 } # Dec 31 2017

      # Calculate Measures
      after(:build) do |bundle|
        options = { 'includeHighlighting' => true, 'calculateHTML' => true, 'measurementPeriodStart' => '2019-01-01', 'measurementPeriodEnd' => '2019-12-31' }
        patient_ids = bundle.fhir_patient_bundles.map { |p| p.id.to_s }
        SingleMeasureCalculationJob.perform_now(patient_ids, bundle.fhir_measure_bundles.first.id, bundle.id.to_s, options)
      end
    end
  end
end
