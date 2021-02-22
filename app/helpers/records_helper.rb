module RecordsHelper
  CV_POPULATION_KEYS = %w[IPP MSRPOPL MSRPOPLEX OBSERV].freeze
  PROPORTION_POPULATION_KEYS = %w[IPP DENOM NUMER DENEX DENEXCEP].freeze
  POPULATION_MAP = { 'IPP' => 'initial-population',
                     'DENOM' => 'denominator',
                     'NUMER' => 'numerator',
                     'DENEX' => 'denominator-exclusion',
                     'DENEXCEP' => 'denominator-exception',
                     'MSRPOPL' => 'measure-population',
                     'MSRPOPLEX' => 'measure-population-exclusion',
                     'OBSERV' => 'measure-observation' }.freeze

  def full_name(patient)
    patient.givenNames.join(' ') + ' ' + patient.familyName if patient
  end

  # { display_name: '', populations: {} }
  def group_calculation_results(measure_report)
    grouped_results = []
    measure_report.group.each do |population_group|
      grouped_results << { display_name: population_group.id, populations: population_group.population }
      population_group.stratifier.each do |stratifier|
        grouped_results << { display_name: stratifier.code[0].text, populations: stratifier.stratum[0].population }
      end
    end
    grouped_results
  end

  def population_label(bundle, pop)
    bundle.modified_population_labels && bundle.modified_population_labels[pop] ? bundle.modified_population_labels[pop] : pop
  end

  def hide_patient_calculation?
    # Hide measure calculation if Cypress is in ATL Mode and the current user is not an ATL or admin
    Settings.current.mode_atl? && (!current_user.user_role?('admin') && !current_user.user_role?('atl'))
  end
end
