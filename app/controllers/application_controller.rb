class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # rescue_from ActionController::RoutingError, with: :render_404  
  # protect_from_forgery with: :exception
  before_filter :set_user


  def render_404
    respond_to do |format|
      format.html redirect_to :back
    end
  end

  def set_user
    @current_user = current_user
    @root_url = Rails.application.routes.url_helpers.root_url(host: request.host_with_port)
    # @current_user ||= User.find(session[:monologue_user_id]) if session[:monologue_user_id]

  end

  def after_sign_in_path_for(resource)
    session[:monologue_user_id] = current_user.id
    return call_path
  end
  
end
