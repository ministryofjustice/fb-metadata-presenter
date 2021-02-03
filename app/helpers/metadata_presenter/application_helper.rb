module MetadataPresenter
  module ApplicationHelper
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
