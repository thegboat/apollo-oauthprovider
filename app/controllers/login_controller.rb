class LoginController < ActionController::Base
  protect_from_forgery
  def index
    @user = User.new
  end
end
