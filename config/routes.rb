Rails.application.routes.draw do
  namespace :api do
    resource :stocks, only: [] do
      collection do
        get :detail
        get :financial_statement
        get :auto_trace_judgment
      end
    end

    resource :books, only: [] do
      collection do
        get :pl
        get :bs
        get :cf
      end
    end

    resource :bollingers, only: [:show]
    resource :rsis, only: [:show]
    resource :deviations, only: [:show]
    resource :psychologicals, only: [:show]
    resource :macds, only: [:show]
    resource :many_signals, only: [:show]
  end
end
