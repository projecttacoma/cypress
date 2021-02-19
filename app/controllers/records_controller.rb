class RecordsController < ApplicationController
  include RecordsHelper
  before_action :set_record_source, only: %i[index show by_measure]

  respond_to :js, only: [:index]

  def index
    unless Bundle.default
      @patients = []
      @measures = []
      add_breadcrumb 'Master Patient List', :records

      return
    end

    return redirect_to bundle_records_path(Bundle.default) unless params[:bundle_id] || params[:vendor_id]

    # create json with the display_name and url for each measure
    @measure_dropdown = measures_for_source
    if @vendor
      @patients = @vendor.fhir_patient_bundles.where(bundle: @bundle.id)
    else
      @patients = @source.fhir_patient_bundles.order_by(first: 'asc')
      @mpl_bundle = Bundle.find(params[:mpl_bundle_id]) if params[:mpl_bundle_id]
    end
  end

  def show
    @record = @source.fhir_patient_bundles.find(params[:id])
    @results = PatientMeasureReport.where(patient_id: @record.id).keep_if(&:in_ipp?)
    @measures = MeasureBundle.find(@results.map(&:measure_id))
    @relevant_entries = params[:measure_id] ? scoop_and_filter(params[:measure_id]) : @record.patient.entry
    @continuous_measures = @measures.select { |measure| measure.measure_scoring == 'continuous-variable' }
    @proportion_measures = @measures.select { |measure| measure.measure_scoring == 'proportion' }
    expires_in 1.week, public: true
    add_breadcrumb 'Patient: ' + @record.givenNames.join(' ') + ' ' + @record.familyName, :record_path
  end

  def scoop_and_filter(measure_id)
    patient_measure_report = @results.select { |pmr| pmr.measure_id.to_s == measure_id }.first
    @record.relevant_entries_for_measure_report(patient_measure_report)
  end

  def by_measure
    source_patients = @vendor&.fhir_patient_bundles
    source_patients ||= @source&.fhir_patient_bundles

    patient_ids = source_patients.map(&:id)
    if params[:measure_id]
      @results = PatientMeasureReport.where(patient_id: { '$in': patient_ids }, measure_id: params[:measure_id]).keep_if(&:in_ipp?)
      @patients = PatientBundle.find(@results.map(&:patient_id))
      @measure = MeasureBundle.find(params[:measure_id])
    end
  end

  def download_mpl
    if BSON::ObjectId.legal?(params[:format])
      bundle = Bundle.find(BSON::ObjectId.from_string(params[:format]))

      if bundle.mpl_status != :ready
        flash[:info] = 'This bundle is currently preparing for download.'
        redirect_to :back
      else
        file = File.new(bundle.mpl_path)
        expires_in 1.month, public: true
        send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "bundle_#{bundle.version}_mpl.zip"
      end
    else
      render body: nil, status: :bad_request
    end
  end

  private

  # note: case vendor will also have a bundle id
  def set_record_source
    if params[:vendor_id]
      set_record_source_vendor
    else
      set_record_source_bundle
    end
  end

  # sets the record source to bundle for the master patient list
  def set_record_source_bundle
    # TODO: figure out what scenarios lead to no params[:bundle_id] here
    @source = @bundle = params[:bundle_id] ? Bundle.available.find(params[:bundle_id]) : Bundle.default
    return unless @bundle

    add_breadcrumb 'Master Patient List', bundle_records_path(@bundle)
    @title = 'Master Patient List'
  end

  def set_record_source_vendor
    @bundle = params[:bundle_id] ? Bundle.available.find(params[:bundle_id]) : Bundle.default
    @vendor = Vendor.find(params[:vendor_id])
    @source = @vendor
    breadcrumbs_for_vendor_path
    @title = "#{@vendor.name} Uploaded Patients"
  end

  def breadcrumbs_for_vendor_path
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb 'Vendor: ' + @vendor.name, vendor_path(@vendor)
    add_breadcrumb 'Patient List', vendor_records_path(vendor_id: @vendor.id, bundle_id: @bundle&.id)
  end

  def measures_for_source
    Rails.cache.fetch("#{@source.cache_key}/measure_dropdown") do
      if @vendor
        @bundle.fhir_measure_bundles.map do |m|
          { label: m.name,
            value: by_measure_vendor_records_path(@vendor, measure_id: m.id, bundle_id: @bundle.id) }
        end.sort_by(&:label)
      else
        @source.fhir_measure_bundles.map do |m|
          { label: m.name,
            value: by_measure_bundle_records_path(@bundle, measure_id: m.id) }
        end.sort_by(&:label)
      end.to_json.html_safe
    end
  end
end
