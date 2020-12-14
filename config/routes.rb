MetadataPresenter::Engine.routes.draw do
  root to: 'service#start'

  post '/reserved/:page_url/answers', to: 'service#answers', as: :reserved_answers
  post '/reserved/confirmation', to: 'service#confirmation', as: :reserved_confirmation
  match '*path', to: 'service#render_page', via: :all
end
