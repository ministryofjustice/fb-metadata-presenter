MetadataPresenter::Engine.routes.draw do
  root to: 'service#start'

  post '/reserved/submissions', to: 'submissions#create', as: :reserved_submissions
  get '/reserved/change-answer', to: 'change_answer#create', as: :change_answer

  # We are not adding rails ujs to the editor app so we need to make it
  # as get verb.
  get '/reserved/file/:component_id', to: 'file#destroy', as: :remove_file

  get 'session/expired', to: 'session#expired'

  get 'save', to: 'save_and_return#show'
  post 'saved_forms', to: 'save_and_return#create'

  post '/', to: 'answers#create'
  match '*path', to: 'answers#create', via: :post
  match '*path', to: 'pages#show',
    via: :all,
    constraints: lambda {|req| req.path !~ /\.(png|jpg|js|css|ico)$/ }
end
