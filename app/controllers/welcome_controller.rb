class WelcomeController < ApplicationController
  def index
    page[:primary_nav] = :home
  end
end
