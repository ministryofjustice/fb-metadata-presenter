MetadataPresenter::Engine.routes.draw do
  root to: 'service#start'

  post '/reserved/submissions', to: 'submissions#create', as: :reserved_submissions
  get '/reserved/change-answer', to: 'change_answer#create', as: :change_answer
  delete '/reserved/file/:component_id', to: 'file#destroy', as: :remove_file

  post '/', to: 'answers#create'
  match '*path', to: 'answers#create', via: :post
  match '*path', to: 'pages#show',
    via: :all,
    constraints: lambda {|req| req.path !~ /\.(png|jpg|js|css|ico)$/ }
end
