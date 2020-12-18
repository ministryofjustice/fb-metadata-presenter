MetadataPresenter::Engine.routes.draw do
  root to: 'service#start'

  post '/reserved/:page_url/answers', to: 'answers#create', as: :reserved_answers
  post '/reserved/submissions', to: 'submissions#create', as: :reserved_submissions
  post '/reserved/change-answer', to: 'change_answer#create', as: :change_answer
  match '*path', to: 'pages#show', via: :all
end
