
namespace :users do
  devise_scope :user do
    post :validate_otp, to: "sessions#validate_otp"
  end

  resource :multi_factor_authentication, only: %i[new show create] do
    post :backup_codes, action: :create_backup_codes
    delete :backup_codes, action: :destroy_backup_codes
  end
end

resource :dashboards, only: [:show]
resource :publics, only: [] do
  get :home
end
