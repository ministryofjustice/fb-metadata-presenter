module MetadataPresenter
  class EngineController < MetadataPresenter.parent_controller.constantize
    protect_from_forgery with: :exception

    helper MetadataPresenter::ApplicationHelper
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def back_link
      return if @page.blank?

      previous_page = service.previous_page(
        current_page: @page,
        referrer: request.referrer
      )&.url

      @back_link ||= File.join(request.script_name, previous_page) if previous_page
    end
    helper_method :back_link

    private

    def not_found
      render template: 'errors/404', status: :not_found
    end

    def redirect_to_page(url)
      redirect_to File.join(request.script_name, url)
    end
  end
end
