module MetadataPresenter
  class SessionController < EngineController
    skip_before_action :require_basic_auth

    def expired; end

    def complete; end
  end
end
