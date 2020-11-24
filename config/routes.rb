MetadataPresenter::Engine.routes.draw do
  root to: 'service#start'

  post '/reserved/answers', to: 'service#answers'
  match '*path', to: 'service#render_page', via: :all
end
