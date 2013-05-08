class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.create!(params[:user])
    sign_in_and_redirect @user
  end

end