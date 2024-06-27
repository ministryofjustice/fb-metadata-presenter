module MetadataPresenter
  class ServiceController < EngineController
    def start
      if use_external_start_page?
        return redirect_to_next_page
      end

      @page = service.start_page
      render template: @page.template
    end

    def form_page_title
      if @page
        if @page.components.present?
          if @page.components.first['label'].present?
            "#{@page.components.first['label']} - #{service.service_name} - GOV.UK"
          elsif @page.components.first['legend'].present?
            "#{@page.components.first['legend']} - #{service.service_name} - GOV.UK"
          end
        elsif @page.heading.present?
          "#{@page.heading} - #{service.service_name} - GOV.UK"
        else
          service.present? && service.service_name ? "#{service.service_name} - GOV.UK" : 'MoJ Forms'
        end
      else
        service.present? && service.service_name ? "#{service.service_name} - GOV.UK" : 'MoJ Forms'
      end
    end
    helper_method :form_page_title

    private

    def redirect_to_next_page
      next_page = NextPage.new(
        service:,
        session:,
        user_data: reload_user_data,
        current_page_url: service.start_page.url,
        previous_answers: []
      ).find

      if next_page.present?
        redirect_to_page next_page.url
      else
        not_found
      end
    end
  end
end
