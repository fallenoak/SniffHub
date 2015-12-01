class SessionsController < ApplicationController
  skip_before_action :require_user

  def new
    # Only guests can log in.
    if current_user?
      redirect_to('/')
      return
    end

    page[:primary_nav] = :login

    @user = User.new
  end

  def create
    params.require(:user).permit(:email, :password)

    page[:primary_nav] = :login

    begin
      @user = User.authenticate!(params[:user][:email], params[:user][:password])
    rescue ActiveRecord::RecordInvalid => e
      @user = e.record

      render(action: :new)
      return
    end

    @current_user = @user
    session[:current_user_id] = current_user.id

    if session[:login_redirect].nil?
      redirect_to('/')
    else
      login_redirect = session.delete(:login_redirect)
      redirect_to(login_redirect)
    end
  end

  def destroy
    @current_user = nil

    session.delete(:current_user_id)
    reset_session

    redirect_to('/')
  end
end
