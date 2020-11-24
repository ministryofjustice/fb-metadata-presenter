class ApplicationController < ActionController::Base

  def service_metadata
    Rails.configuration.service_metadata
  end

  def save_user_data
    session[:user_data] = { something: 'answer' }
  end

  def load_user_data
    Rails.logger.info('=' * 80)
    Rails.logger.info(session[:user_data])
    Rails.logger.info('=' * 80)
    session[:user_data]
  end
end
