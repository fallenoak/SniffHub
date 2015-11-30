class CapturesController < ApplicationController
  def index
    page[:primary_nav] = :captures

    @captures = Capture
  end

  def show
    page[:primary_nav] = :captures

    @capture = Capture.find(params[:id])
  end
end
