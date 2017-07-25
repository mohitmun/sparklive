class User::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    password = params["user"]["password"]
    email = params["user"]["email"]
    role = params[:doctor].blank? ? "patient" : "doctor"
    params.permit!
    user = User.find_by(username: email) rescue User.find_by(email: email) rescue nil
    if user
      if user.valid_password?(password)
      end
    else
      user = User.create(email: email, password: password, role: role)
      hospital = Hospital.find(params["user"]["hospital"]) rescue nil
      if !hospital.blank?
        hospital.add_member(user)
      end
    end
    sign_in user
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
