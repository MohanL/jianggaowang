class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :detect_device_format, :set_redirect_to_path

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  rescue_from(ActionView::MissingTemplate) do |e|
    request.format = :html
    render_404
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id] if session[:user_id]
  end

  def authenticate_user!
    unless current_user
      if request.xhr?
        render json: {message: "请先登录后再执行操作！"}, status: 403
      else
        session[:return_to] = request.path

        flash[:danger] = "请先登录"
        redirect_to login_path
      end
    end
  end

  def render_404
    render file: 'public/404.html', layout: false
  end

  def after_sign_in_path
    return_to = session[:return_to] || root_path

    # reset after used
    session[:return_to] = nil

    return_to
  end

  private

  def detect_device_format
    case request.user_agent
    when /iPad/i
      request.variant = :tablet
    when /iPhone/i
      request.variant = :phone
    when /Android/i && /mobile/i
      request.variant = :phone
    when /Android/i
      request.variant = :tablet
    when /Windows Phone/i
      request.variant = :phone
    end
  end

  def set_redirect_to_path
    if self.class != UserPasswordsController && self.class != SessionsController && self.class != UsersController && !request.xhr?
      session[:return_to] = request.url
    end
  end
end
