Rails.application.routes.draw do
  namespace :api do
    resources :stocks, only: [] do
      collection do
        get :detail
        get :financial_statement
        get :auto_trace_judgment
      end
    end

    resources :books, only: [] do
      collection do
        get :pl
        get :bs
        get :cf
      end
    end
  end
end
