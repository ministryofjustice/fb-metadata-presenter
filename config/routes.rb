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
  get 'save/email_confirmation', to: 'save_and_return#email_confirmation'
  post 'email_confirmations', to: 'save_and_return#confirm_email'
  get 'save/progress_saved', to: 'save_and_return#save_progress'
  get 'return/:service_slug/:uuid', to: 'save_and_return#return'
  post 'resume_forms', to: 'save_and_return#submit_secret_answer'
  get 'record_error', to: 'save_and_return#record_error'
  get 'record_failure', to: 'save_and_return#record_failure'
  get 'expired', to: 'save_and_return#record_link_expired'
  get 'already_used', to: 'save_and_return#record_link_used'
  get 'resume_from_start', to: 'save_and_return#resume_from_start'
  get 'resume', to: 'save_and_return#resume'

  post '/', to: 'answers#create'
  match '*path', to: 'answers#create', via: :post
  match '*path', to: 'pages#show',
    via: :all,
    constraints: lambda {|req| req.path !~ /\.(png|jpg|js|css|ico)$/ }
end
