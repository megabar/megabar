class MegaBar::SessionsController < ApplicationController
  def new
  end 

  def create

    user = MegaBar::User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to '/', notice: "logged In"
    else
      flash.now.alert = "Email or password is invalid"
      render "new"
    end 
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/', notice: "Logged Out"
  end
end
