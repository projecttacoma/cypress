class Summary < Mustache

  self.template_path = __dir__

  def initialize(patient_bundle)
    @patient_bundle = patient_bundle
  end

  def patient_entry
    @patient_bundle['entry'].select { |pe| pe['resource']['resourceType'] == 'Patient' }.map(&:resource)
  end

  def non_patient_entries
    @patient_bundle['entry'].select { |pe| !['Patient', 'MeasureReport'].include? pe['resource']['resourceType'] }.map(&:resource)
  end  
end
