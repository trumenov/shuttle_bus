Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :path => '/profile', controllers: { sessions: 'users/sessions', registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks' }

  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'pages#main_page'
  # get '/test_path', to: 'pages#test_path'
  get '/about'    , to: 'pages#about'
  get '/gifs_some1'    , to: 'pages#gifs_some1'

  # get '/parties'                                , to: 'pages#front_parties_list'
  # get '/parties/:party_id'                      , to: 'pages#front_parties_edit'
  # get '/parties/:party_id/buy_ticket/:tpack_id' , to: 'pages#front_parties_buy_ticket'

  resources :queues, module: :pub_task_queues, param: :tq_id, only: [:index, :show, :update] do

  end
  # resources :tasks, module: :front_users_module, param: :front_user_id, only: [:index, :show] do

  #   end

  resources :users, module: :front_users_module, param: :front_user_id, only: [:index, :show] do

  end

  resources :parties, module: :parties_module, param: :party_id, only: [:index, :show] do
    resources :tickets, module: :buy_ticket_module, param: :tpack_id, only: [:index] do

    end
    member do
      get :chat
      post :chat, to: 'parties#chat_add_msg'
    end
  end

  resources :trips, module: :pub_trips, param: :tr_id, only: [:index, :show] do
    resources :points, param: :trp_id, only: [:index, :show] do

    end
    member do
      get :chat
      post :chat, to: 'trips#chat_add_msg'
    end
  end

  resources :stations, module: :pub_stations, param: :st_id, only: [:index, :show] do

  end


  get  '/profile'                             , to: 'front_profile#user_profile_show', as: :user_root
  get  '/profile/public_info'                 , to: 'front_profile#user_profile_public_info_edit'
  post '/profile/public_info'                 , to: 'front_profile#user_profile_public_info_save'
  get  '/profile/password_change'             , to: 'front_profile#user_profile_password_change_edit'
  post '/profile/password_change'             , to: 'front_profile#user_profile_password_change_save'
  get  '/profile/change_email'                , to: 'front_profile#user_profile_change_email_edit'
  post '/profile/change_email'                , to: 'front_profile#user_profile_change_email_save'
  post '/profile/subscribe_notifications'     , to: 'front_profile#subscribe_notifications'
  post '/demo_push'                           , to: 'pages#demo_push'
  # get  '/profile/my_events'                   , to: 'front_profile#user_profile_my_events_list'
  # get  '/profile/my_events/:my_event_id'      , to: 'front_profile#user_profile_my_events_show'
  # post '/profile/my_events/:my_event_id'      , to: 'front_profile#user_profile_my_events_save'
  # get  '/profile/my_events/:my_event_id/edit' , to: 'front_profile#user_profile_my_events_show'
  # PAYMENT CALLBACKS STARTED
  # post "/webhooks/stripe", to: "pay/webhooks/stripe#create"

  get  "/payment_success/:ticket_payment_id", to: 'pages#ticket_transaction_payment_success'
  get  "/payment_cancel/:ticket_payment_id" , to: 'pages#ticket_transaction_payment_cancel'


  get '/vehicle_img_sm/:vimg_id', :controller => :pages, action: :pub_vehicle_sm_img
  get '/user_station_img_sm/:simg_id', :controller => :pages, action: :pub_user_station_sm_img

  namespace :profile, format: false do
    resources :my_payout_options, module: :my_payout_options, param: :poption_id
    resources :my_notifications, module: :my_notifications, param: :my_notification_id, only: [:index, :show]
    resources :my_tickets, module: :my_tickets, param: :ticket_id, only: [:index, :new, :show, :create, :update] do
      get :pay
    end
    resources :my_vehicles, module: :my_vehicles, param: :my_vehicle_id do
      resources :vehicle_imgs, param: :eimg_id, only: %w{index create destroy} do

      end
      member do
        post :choose_vimage_as_logo
      end
    end

    resources :my_stations, module: :my_stations, param: :my_station_id do
      resources :station_imgs, param: :simg_id, only: %w{index create destroy} do

      end
      member do
        post :choose_simage_as_logo
      end
    end

    resources :my_routes, module: :my_routes, param: :my_route_id do
      resources :route_points, param: :rp_id do

      end
      # member do
      #   post :choose_simage_as_logo
      # end
    end

    resources :my_trips, module: :my_trips, param: :my_trip_id do
      resources :trip_points, param: :trp_id do

      end
      member do
        get  :publish_flag
        post :publish_flag, to: 'my_trips#publish_flag_update'
      end
      # resources :route_points, param: :rp_id do

      # end
    end

    resources :my_events, module: :my_events, param: :my_event_id do
      resources :tickets_packs, param: :tpack_id do

      end
      member do
        get :images
        get  :my_chat
        post :my_chat, to: 'my_events#my_chat_add_msg'
        get  :payout
        post :payout , to: 'my_events#payout_run'
        post   :choose_image_as_logo
        post   :create_image_attachment
        post   :change_event_status
      end
    end

    resources :sold_tickets, module: :sold_tickets, param: :sold_ticket_id
  end

end
