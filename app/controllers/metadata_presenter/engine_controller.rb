module MetadataPresenter
  class EngineController < MetadataPresenter.parent_controller.constantize
    protect_from_forgery with: :exception

    helper MetadataPresenter::ApplicationHelper
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def reload_user_data
      if defined? super
        super
      else
        load_user_data
      end
    end

    def back_link
      previous_page = PreviousPage.new(
        service: service,
        user_data: load_user_data,
        current_page: @page,
        referrer: request.referrer
      ).page

      if previous_page
        @back_link ||= File.join(
          request.script_name,
          previous_page.url
        )
      end
    end
    helper_method :back_link

    def answered?(component_id)
      @page_answers.send(component_id).present?
    end
    helper_method :answered?

    def analytics_cookie_name
      @analytics_cookie_name ||= "analytics-#{service.service_name.parameterize}"
    end
    helper_method :analytics_cookie_name

    def allow_analytics?
      cookies[analytics_cookie_name] == 'accepted'
    end
    helper_method :allow_analytics?

    def show_cookie_banner?
      no_analytics_cookie?
    end
    helper_method :show_cookie_banner?

    private

    def not_found
      render template: 'errors/404', status: :not_found
    end

    def redirect_to_page(url)
      redirect_to File.join(request.script_name, url)
    end

    def analytics_tags_present?
      Rails.application.config.supported_analytics.values.flatten.any? do |analytic|
        ENV[analytic].present?
      end
    end

    def no_analytics_cookie?
      cookies[analytics_cookie_name].blank?
    end
  end
end
