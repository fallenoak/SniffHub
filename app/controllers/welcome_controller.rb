class WelcomeController < ApplicationController
  skip_before_action :require_user, only: :index

  def index
    page[:primary_nav] = :home

    if current_user?
      load_home
    else
      load_welcome
    end
  end

  private def load_home
    @recent_uploads = current_user.uploads.order('uploads.uploaded_at DESC').limit(5)
  end

  private def load_welcome
  end
end
