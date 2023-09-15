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

    def save_form_progress
      if defined? super
        super
      end
    end

    def get_saved_progress(uuid)
      if defined? super
        super(uuid)
      end
    end

    def increment_record_counter(uuid)
      if defined? super
        super(uuid)
      end
    end

    def invalidate_record(uuid)
      if defined? super
        super(uuid)
      end
    end

    def back_link
      previous_page = PreviousPage.new(
        service:,
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

    def show_cookie_request?
      (Rails.application.config.respond_to?(:global_ga4) || analytics_tags_present?) && no_analytics_cookie?
    end
    helper_method :show_cookie_request?

    def show_cookie_confirmation?
      unless no_analytics_cookie?
        (Rails.application.config.respond_to?(:global_ga4) || analytics_tags_present?) && params[:analytics].present?
      end
    end
    helper_method :show_cookie_confirmation?

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

      if editor_preview?
        File.join(request.script_name, link)
      else
        link.starts_with?('/') ? link : link.prepend('/')
      end
    end
    helper_method :external_or_relative_link

    def load_conditional_content
      if @page.content_component_present?
        conditional_components_uuids(@page)
      end
    end
    helper_method :load_conditional_content

    def components_without_conditionals(page)
      page.content_components.select { |component|
        component.conditionals.blank?
      }.map(&:uuid)
    end

    def list_conditional_components
      @page.content_components.map(&:uuid).compact
    end

    def show_components(page)
      return @page.content_components.map(&:uuid) if editor_preview?

      conditional_components_uuids(page)
    end

    def conditional_components_uuids(page)
      page.content_components.map do |content_component|
        evaluator = EvaluateContentConditionals.new(service:, component: content_component, user_data: load_user_data)
        evaluator.uuids_to_include
      end
    end

    private

    def not_found
      render template: 'errors/404', status: :not_found
    end

    def internal_server_error
      render template: 'errors/500', status: :internal_server_error
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

    def editor_preview?
      URI(request.original_url).path.split('/').include?('preview')
    end
  end
end
