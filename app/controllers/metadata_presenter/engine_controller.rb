module MetadataPresenter
  class EngineController < MetadataPresenter.parent_controller.constantize
    protect_from_forgery with: :exception

    helper MetadataPresenter::ApplicationHelper
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    before_action :show_maintenance_page

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
      (Rails.application.config.respond_to?(:global_ga4) || analytics_tags_present?) && no_analytics_cookie?
    end
    helper_method :show_cookie_banner?

    def analytics_tags_present?
      Rails.application.config.supported_analytics.values.flatten.any? do |analytic|
        ENV[analytic].present?
      end
    end
    helper_method :analytics_tags_present?

    def load_autocomplete_items
      if @page.autocomplete_component_present?
        items = autocomplete_items(@page.components)
        @page.assign_autocomplete_items(items)
      end
    end

    def maintenance_mode?
      ENV['MAINTENANCE_MODE'].present? && ENV['MAINTENANCE_MODE'] == '1'
    end

    def external_or_relative_link(link)
      uri = URI.parse(link)
      return link if uri.scheme.present? && uri.host.present?

      link.starts_with?('/') ? link : link.prepend('/')
    end
    helper_method :external_or_relative_link

    private

    def not_found
      render template: 'errors/404', status: :not_found
    end

    def redirect_to_page(url)
      redirect_to File.join(request.script_name, url)
    end

    def no_analytics_cookie?
      cookies[analytics_cookie_name].blank?
    end

    def maintenance_page_content
      return t('presenter.maintenance.maintenance_page_content') unless ENV['MAINTENANCE_PAGE_CONTENT']

      Base64.decode64(ENV['MAINTENANCE_PAGE_CONTENT'])
    end

    def show_maintenance_page
      if maintenance_mode?
        @maintenance_page = {
          heading: ENV['MAINTENANCE_PAGE_HEADING'] || t('presenter.maintenance.maintenance_page_heading'),
          content: maintenance_page_content
        }

        render 'metadata_presenter/maintenance/show'
      end
    end
  end
end
