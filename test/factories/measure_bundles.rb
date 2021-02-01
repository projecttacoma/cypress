FactoryBot.define do
  factory :measure_bundle, class: MeasureBundle do
    entry = Rails.root.join('test', 'fixtures', 'fhir', 'measure-bundle.json')
    transient do
      seq_id { 1 }
    end
    source_measure = JSON.parse(File.read(entry), max_nesting: 100)

    measure_bundle_hash { source_measure }
  end
end
