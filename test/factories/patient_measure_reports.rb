# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient_measure_reports, class: PatientMeasureReport do
    measure_report_hash { { 'measure' => 'http://hl7.org/fhir/us/cqfmeasures/Measure/measure-EXM111' } }
  end
end
