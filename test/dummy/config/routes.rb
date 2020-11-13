Rails.application.routes.draw do
  mount Fb::Metadata::Presenter::Engine => "/fb-metadata-presenter"
end
