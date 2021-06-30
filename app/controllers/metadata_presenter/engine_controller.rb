module MetadataPresenter
  class EngineController < MetadataPresenter.parent_controller.constantize
    protect_from_forgery with: :exception

    helper MetadataPresenter::ApplicationHelper
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def back_link
      previous_page = PreviousPage.new(
        service: service,
        user_data: load_user_data,
        current_page: @page,
        referer: request.referer
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

    private

    def not_found
      render template: 'errors/404', status: :not_found
    end

    def redirect_to_page(url)
      redirect_to File.join(request.script_name, url)
    end
  end
end
