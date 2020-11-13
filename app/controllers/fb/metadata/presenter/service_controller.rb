class Fb::Metadata::Presenter::ServiceController < ApplicationController
  def start
    @service = Fb::Metadata::Presenter::Service.new
    @start_page = @service.pages.first
  end
end
