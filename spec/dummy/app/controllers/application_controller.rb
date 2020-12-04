class ApplicationController < ActionController::Base
  def service
    @service ||= MetadataPresenter::Service.new(service_metadata)
  end

  def service_metadata
    Rails.configuration.service_metadata
  end

  def save_user_data
    if params[:answers]
      session[:user_data] ||= {}

      params[:answers].each do |field, answer|
        session[:user_data][field] = answer
      end
    end
  end

  def load_user_data
    session[:user_data] || {}
  end

  def default_metadata
    Rails.application.config.default_metadata
  end
end
