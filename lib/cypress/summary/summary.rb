class Summary < Mustache

  self.template_path = __dir__

  def initialize(relevant_entries)
    @relevant_entries = relevant_entries
  end

  def patient_entry
    @relevant_entries.select { |pe| pe.resource.resourceType == 'Patient' }.map(&:resource)
  end

  def non_patient_entries
    @relevant_entries.select { |pe| !['Patient', 'MeasureReport'].include? pe.resource.resourceType }.map(&:resource)
  end

  def check_race(url)
    render(url) == "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race"
  end

  def check_ethnicity(url)
    render(url) == "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity"
  end
end
