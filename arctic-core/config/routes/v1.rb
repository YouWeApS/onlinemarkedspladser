# frozen_string_literal: true

Rails.application.routes.draw do
  # Namespace won't work for Doorkeeper. Using scope instead
  scope :v1 do
    scope :ui do
      use_doorkeeper do
        skip_controllers \
          :applications,
          :authorized_applications
      end
    end
  end

  namespace :v1 do
    namespace :ui do
      namespace :admin do
        resources :accounts, except: :new
      end

      post :recover_password, to: 'recover_password#start_flow'
      post :reset_password, to: 'recover_password#reset'

      resources :users, only: %i[update] do
        post '', on: :member, action: :update
      end
      get :me, to: 'users#show'

      get :vendors, to: 'vendors#all'

      get :currencies, to: 'utils#currencies'
      get :shipping_carriers, to: 'utils#shipping_carriers'
      get :shipping_methods, to: 'utils#shipping_methods'

      resources :accounts, only: %i[index] do
        resources :shops, only: %i[index] do
          resources :vendors, only: %i[index create] do
            post 'products/disperse', to: 'products#disperse'
            get 'products/raw', to: 'products#raw'

            resources :import_maps, only: %i[create update destroy]

            resources :shipping_configurations, only: %i[create destroy]

            resources :products, only: %i[index show update destroy] do
              put :import, on: :collection
              get :export, on: :collection
              patch :enable, on: :collection
              resources :errors, only: :destroy do
                delete :destroy_all, on: :collection
              end
              resources :images, only: [] do
                patch :update, on: :member
              end
            end

            resources :categories, only: %i[index show update create destroy]

            resource :vendor_shop_configurations, path: :config, only: %i[show update]

            resources :orders, only: %i[index show] do
              get :statuses, on: :collection
            end
          end
        end
      end

      # None-production environment endpoints.
      # E.g. testing webhooks, emails, etc.
      unless Rails.env.production?
        namespace :tests do
          resources :accounts do
            resources :shops do
              resources :vendors do
                post 'webhooks/:webhook', to: 'webhooks#test'
              end
            end
          end
        end
      end
    end

    namespace :vendors do
      resources :shops, only: %i[index show] do
        patch ':id/products_synced', on: :collection, to: 'shops#products_synced'
        patch ':id/orders_synced', on: :collection, to: 'shops#orders_synced'

        resources :currencies, only: %i[index] do
          put '', on: :collection, action: :update
        end

        resources :products, only: %i[create index update] do
          resources :product_errors, path: :errors, only: :create
          get 'last_synced_at', on: :collection, action: :last_synced_at
          get 'update_scheduled', on: :collection, action: :update_scheduled
        end

        resources :orders, only: %i[index create update show] do
          get 'last_synced_at', on: :collection, action: :last_synced_at
          post :lock, action: :lock
          delete :lock, action: :unlock

          resources :invoices, only: :create, controller: :order_invoices
          resources :order_lines, only: %i[update create] do
            get :statuses, on: :collection
          end
        end
      end
    end
  end
end
