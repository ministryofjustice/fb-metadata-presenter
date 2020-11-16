class MetadataPresenter::ServiceController < ApplicationController
  def start
    @service = MetadataPresenter::Service.new
    @start_page = @service.pages.first
  end
end
