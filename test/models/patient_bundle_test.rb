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
end
