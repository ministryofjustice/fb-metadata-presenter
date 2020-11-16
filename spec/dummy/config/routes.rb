Rails.application.routes.draw do
  mount MetadataPresenter::Engine => "/metadata_presenter"
end
