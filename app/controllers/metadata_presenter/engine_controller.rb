module MetadataPresenter
  class EngineController < MetadataPresenter.parent_controller.constantize
    protect_from_forgery with: :exception

    helper MetadataPresenter::ApplicationHelper
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def back_link
      return if @page.blank?

      @back_link ||= service.previous_page(current_page: @page)&.url
    end
    helper_method :back_link

    private

    def not_found
      render template: 'errors/404', status: 404
    end

    def redirect_to_page(url)
      redirect_to File.join(request.script_name, url)
    end
  end
end
