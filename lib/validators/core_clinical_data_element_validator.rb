module Validators
  class CoreClinicalDataElementValidator < QrdaFileValidator
    include Validators::Validator

    def initialize(measures)
      @measures = measures
    end

    def validate(file, options = {})
      return if (APP_CONSTANTS['result_measures'].map(&:hqmf_set_id) & @measures.pluck(:hqmf_set_id)).empty?

      doc = get_document(file)
      encounter_ids = encounter_ids_in_doc(doc)
      # Get Entries related to Core Clinical Data Element (Laboraty Test, Performed (V5) and Physical Exam, Performed (V5)
      ccde_xpath = %(//cda:entry/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.38'
                   or @root='2.16.840.1.113883.10.20.24.3.59']])
      # The related to id is nested within the template
      related_id_xpath = %(./sdtc:inFulfillmentOf1[./sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.150']]/sdtc:actReference/sdtc:id)
      doc.xpath(ccde_xpath).each do |ccde|
        # The ID of the entry
        ccde_id = ccde.at_xpath('./cda:id')
        # string value entry id for use in error message
        ccde_id_string = "#{ccde_id['root']}(root), #{ccde_id['extension']}(extension)"
        # find the "related to" ID for the entry
        related_to_id = ccde.at_xpath(related_id_xpath)
        # If a related to ID can be found, make sure it points to an encounter in the file
        # If a related to ID cannot be found, return an error message
        if related_to_id
          # string value of the related to id for use in error message
          related_to_id_string = "#{related_to_id['root']}(root), #{related_to_id['extension']}(extension)"
          msg = "Referenced Encounter for Core Clinical Data Element entry #{ccde_id_string} cannot be found"
          add_error(msg, file_name: options[:file_name], location: ccde.path) unless encounter_ids.include?(related_to_id_string)
        else
          msg = "Encounter Reference missing for Core Clinical Data Element entry #{ccde_id_string}"
          add_error(msg, file_name: options[:file_name], location: ccde.path)
        end
      end
    end

    # Return a list of encounter ids found in document
    def encounter_ids_in_doc(doc)
      encounter_ids = []
      encounter_ids_xpath = %(//cda:encounter[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.23']]/cda:id)
      doc.xpath(encounter_ids_xpath).each do |encounter_id|
        encounter_ids << "#{encounter_id['root']}(root), #{encounter_id['extension']}(extension)"
      end
      encounter_ids
    end
  end
end
