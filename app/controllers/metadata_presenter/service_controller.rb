class MetadataPresenter::ServiceController < ApplicationController
  def start
    @service = MetadataPresenter::Service.new(service_metadata)
    @start_page = @service.pages.first
  end

  def service_metadata
    return JSON.parse(params[:service_metadata]) if params[:service_metadata]
    Rails.configuration.service_metadata
  end
end
