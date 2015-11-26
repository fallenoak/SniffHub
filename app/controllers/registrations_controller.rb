class RegistrationsController < ApplicationController
  def new
    # Only guests can register.
    if current_user?
      redirect_to('/')
      return
    end

    @user = User.new
  end

  def create
    params.require(:user).permit(:name, :email, :password, :password_confirmation)

    @user = User.new

    @user.name = params[:user][:name]
    @user.email = params[:user][:email]

    @user.should_validate_password = true
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    begin
      @user.save!
    rescue ActiveRecord::RecordInvalid => e
      render(action: :new)
      return
    end

    @current_user = @user
    session[:current_user_id] = current_user.id

    redirect_to('/')
  end
end
