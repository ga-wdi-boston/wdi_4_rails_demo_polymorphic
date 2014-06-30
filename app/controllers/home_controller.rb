class HomeController < ApplicationController
  def show
    @statuses = Status.order(created_at: :desc)
    @links = Link.order(created_at: :desc)
  end
end
