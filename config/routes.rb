#Rails.application.routes.draw do
GetBack::Engine.routes.draw do
  resources :db_backups do
    post :restore
  end

  resources :file_backups do
    post :restore
  end

  post :aws_subscription_notify, :to => 'aws_sns_subscriptions#create'
  post :aws_archive_retrieval_job_create, :to => 'aws_archive_retrieval_jobs#create'
  post :aws_fetch_archive, :to => 'aws_archives#fetch'
end
