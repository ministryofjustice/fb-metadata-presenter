module Fb
  module Metadata
    module Presenter
      class ApplicationController < ActionController::Base
        protect_from_forgery with: :exception
      end
    end
  end
end
