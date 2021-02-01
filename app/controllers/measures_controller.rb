class MeasuresController < ApplicationController
  include API::Controller

  def index
    @measures = Bundle.find(params[:bundle_id]).fhir_measure_bundles
    respond_with(@fhir_measure_bundles.to_a)
  end
end
