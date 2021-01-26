require 'test_helper'

class FqmExecutionCalcTest < ActiveSupport::TestCase
  def setup
    measure_file = create_rack_test_file('test/fixtures/fhir/measure-bundle.json', 'text/json')
    @measure_json = JSON.parse(File.read(measure_file))
    patient_file = create_rack_test_file('test/fixtures/fhir/patient-bundle.json', 'text/json')
    @patient_json = JSON.parse(File.read(patient_file))
    @pb = PatientBundle.create(patient_bundle_hash: @patient_json)
    @mb = MeasureBundle.create(measure_bundle_hash: @measure_json)
  end

  def test_save_measure_report
    options = { 'includeHighlighting' => true, 'calculateHTML' => true }
    assert_equal 0, PatientMeasureReport.all.size
    calc_job = Cypress::FqmExecutionCalc.new([@pb], [@mb], 'correlation_id', options)
    calc_job.execute(true)
    assert_equal 1, PatientMeasureReport.all.size
  end

  def test_fqm_calc
    options = { 'includeHighlighting' => true, 'calculateHTML' => true }
    calc_job = Cypress::FqmExecutionCalc.new([@pb], [@mb], 'correlation_id', options)
    result = calc_job.execute(true)
    expected = { 'initial-population' => 1, 'numerator' => 1, 'denominator' => 1,
                 'denominator-exclusion' => 0, 'denominator-exception' => 0 }
    result.first.group.first.population.each do |population|
      reported_pop = population.code.coding[0].code
      assert_equal expected[reported_pop], population.count
    end
  end
end
