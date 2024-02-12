MetadataPresenter::Engine.routes.draw do
  root to: 'service#start'

  post '/reserved/submissions', to: 'submissions#create', as: :reserved_submissions
  get '/reserved/change-answer', to: 'change_answer#create', as: :change_answer

  # We are not adding rails ujs to the editor app so we need to make it
  # as get verb.
  get '/reserved/file/:component_id', to: 'file#destroy', as: :remove_file
  get '/reserved/file/:component_id/:file_uuid', to: 'file#remove_multifile', as: :remove_multifile

  get 'session/expired', to: 'session#expired'
  get 'session/complete', to: 'session#complete'

  # save form journey
  get 'save', to: 'save_and_return#show'
  post 'saved_forms', to: 'save_and_return#create'
  get 'save/email_confirmation', to: 'save_and_return#email_confirmation'
  post 'email_confirmations', to: 'save_and_return#confirm_email'
  get 'save/progress_saved', to: 'save_and_return#save_progress'

  # resume form journey
  get '/return/:uuid', to: 'resume#return'
  post 'resume_forms', to: 'resume#submit_secret_answer'
  get 'resume_from_start', to: 'resume#resume_from_start'
  get 'resume_progress', to: 'resume#resume_progress'
  get 'record_error', to: 'resume#record_error'
  get 'record_failure', to: 'resume#record_failure'
  get 'expired', to: 'resume#record_link_expired'
  get 'already_used', to: 'resume#record_link_used'

  post '/', to: 'answers#create'
  match '*path', to: 'answers#create', via: :post
  match '*path', to: 'pages#show',
    via: :all,
    constraints: lambda {|req| req.path !~ /\.(png|jpg|js|css|ico)$/ }
end
