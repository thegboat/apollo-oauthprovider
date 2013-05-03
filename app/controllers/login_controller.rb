class LoginController < ActionController::Base
  protect_from_forgery
  def index
    @login = ""
    #redirect_to login_url if !params[:username] and params[:last_name]
    #redirect_to signup_url if !params[:last_name] and params[:username]
  end

  def login

  end

  def signup
   #  @user = API::User.find(params)
  end
end
