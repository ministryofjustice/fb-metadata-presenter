module MetadataPresenter
  class FileController < EngineController
    def destroy
      remove_user_data(params[:component_id])
      redirect_back(fallback_location: root_path)
    end

    def remove_user_data
      super if defined?(super)
    end
  end
end
