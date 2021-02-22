# frozen_string_literal: true

# This class has been adapted from https://github.com/onc-healthit/inferno
# A validator that calls out to the HL7 validator API
class HL7Validator
  ISSUE_DETAILS_FILTER = [
    %r{^Sub-extension url 'introspect' is not defined by the Extension http://fhir-registry\.smarthealthit\.org/StructureDefinition/oauth-uris$},
    %r{^Sub-extension url 'revoke' is not defined by the Extension http://fhir-registry\.smarthealthit\.org/StructureDefinition/oauth-uris$},
    /^URL value .* does not resolve$/,
    /^vs-1: if Observation\.effective\[x\] is dateTime and has a value then that value shall be precise to the day/, # Invalid invariant in FHIRv4.0.1
    /^us-core-1: Datetime must be at least to day/ # Invalid invariant in US Core v3.1.1
  ].freeze
  @validator_url = nil

  def initialize(validator_url)
    raise ArgumentError, 'Validator URL is unset' if validator_url.blank?

    @validator_url = validator_url
  end

  def validate(resource, profile_url = nil)
    return { errors: [], warnings: [], information: ["No profile specified for #{resource.resourceType}"] } unless profile_url

    begin
      result = RestClient.post "#{@validator_url}/validate", resource.to_json, params: { profile: profile_url }
    rescue
      return { errors: [], warnings: [], information: ["Validation not performed for #{resource.resourceType}"] }
    end

    outcome = JSON.parse(result.body)

    issues_by_severity(outcome.issue)
  end

  # @return [String] the version of the validator currently being used or nil
  #   if unable to reach the /version endpoint
  def version
    result = RestClient.get "#{@validator_url}/version"
    result.body
  rescue StandardError
    nil
  end

  private

  def issues_by_severity(issues)
    errors = []
    warnings = []
    information = []

    issues.each do |iss|
      if iss.severity == 'information' || iss.code == 'code-invalid' || ISSUE_DETAILS_FILTER.any? { |filter| filter.match?(iss&.details&.text) }
        information << issue_message(iss)
      elsif iss.severity == 'warning'
        warnings << issue_message(iss)
      else
        errors << issue_message(iss)
      end
    end

    {
      errors: errors,
      warnings: warnings,
      information: information
    }
  end

  def issue_message(issue)
    issue&.details&.text
  end
end
