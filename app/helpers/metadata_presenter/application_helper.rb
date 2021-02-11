module MetadataPresenter
  module ApplicationHelper
    def main_h1(component)
      if component.legend.present?
        content_tag(:legend, class: 'govuk-fieldset__legend govuk-fieldset__legend--l') do
          content_tag(:h1, class: 'govuk-fieldset__heading') do
            component.legend
          end
        end
      else
        content_tag(:h1, class: 'govuk-heading-xl') do
          component.label
        end
      end
    end

    ## Display user answers on the view
    ## When the user doesn't answered yet the component will be blank
    # or with data otherwise, so doing the if in every output is not
    # pratical.
    #
    # The below example search for 'first_name' in the user data instance
    # variable as long your load_user_data in the controller sets the variable.
    #
    # @example
    #   <%=a 'first_name' %>
    #
    def a(component_key)
      if @user_data.present?
        @user_data[component_key]
      end
    end
    alias answer a

    ## Display user answers on the view formatted.
    ##
    def formatted_answer(component_key)
      user_answer = answer(component_key)

      simple_format(user_answer) if user_answer.present?
    end

    # Renders markdown given a text.
    #
    # @example
    #   <%=m '# Some markdown' %>
    #
    def m(text)
      (Kramdown::Document.new(text).to_html).html_safe
    end
    alias to_markdown m
  end
end
