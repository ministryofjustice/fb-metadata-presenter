module MetadataPresenter
  class FileController < EngineController
    def destroy
      remove_user_data(params[:component_id])
      redirect_back(fallback_location: root_path)
    end

    def remove_multifile
      remove_file_from_data(params[:component_id], params[:file_uuid])
      redirect_back(fallback_location: root_path)
    end

    def remove_user_data(component_id)
      super(component_id) if defined?(super)
    end

    def remove_file_from_data(component_id, file_id)
      super(component_id, file_id) if defined?(super)
    end
  end
end
