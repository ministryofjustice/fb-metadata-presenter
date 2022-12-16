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

  def create_submission; end

  def autocomplete_items(component); end

  def show_reference_number; end
  helper_method :show_reference_number

  def reference_number_enabled?; end
  helper_method :reference_number_enabled?

  def payment_link_enabled?; end
  helper_method :payment_link_enabled?

  def payment_link_url; end
  helper_method :payment_link_url

  def default_metadata
    Rails.application.config.default_metadata
  end

  def editable?
    false
  end
  helper_method :editable?
end
