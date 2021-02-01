FactoryBot.define do
  factory :bundle, class: Bundle do
    sequence(:name) { |i| "Bundle Name #{i}" }
    sequence(:version) { |i| "#{2050 + i}.0.0" }
    sequence(:title) { |i| "Bundle Name #{i}" }

    after(:build) do |bundle|
      create(:patient_bundle, seq_id: 1, bundle: bundle)
      create(:measure_bundle, seq_id: 1, bundle: bundle)
    end

    # static_bundle includes random measures that will not execute in the cqm-execution-service
    # use executable_bundle for calculation tests
    factory :static_bundle do
      active { true }
      done_importing { true }
      name { 'Static Bundle' }
      title { 'Static Bundle' }
      version { '2021.0.0' }
      measure_period_start { 1_483_228_800 } # Jan 1 2017
      effective_date { 1_514_764_799 } # Dec 31 2017

      after(:build) do |bundle|
        create(:patient_bundle, seq_id: 1, bundle: bundle)
        create(:measure_bundle, seq_id: 1, bundle: bundle)
      end
    end
  end
end
