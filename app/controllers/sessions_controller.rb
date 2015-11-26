class SessionsController < ApplicationController
  def new
    # Only guests can log in.
    if current_user?
      redirect_to('/')
      return
    end

    @user = User.new
  end

  def create
    params.require(:user).permit(:email, :password)

    begin
      @user = User.authenticate!(params[:user][:email], params[:user][:password])
    rescue ActiveRecord::RecordInvalid => e
      @user = e.record

      render(action: :new)
      return
    end

    @current_user = @user
    session[:current_user_id] = current_user.id

    redirect_to('/')
  end

  def destroy
    @current_user = nil

    session.delete(:current_user_id)
    reset_session

    redirect_to('/')
  end
end
