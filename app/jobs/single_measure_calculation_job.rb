class SingleMeasureCalculationJob < ApplicationJob
  queue_as :measure_calculation
  include Job::Status

  def perform(patient_ids, measure_id, correlation_id, options)
    measure = MeasureBundle.find(measure_id)
    patients = PatientBundle.find(patient_ids)
    calc_job = Cypress::FqmExecutionCalc.new(patients,
                                             [measure],
                                             correlation_id,
                                             options)
    calc_job.execute(true)
  end
end
