class LinksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def show
    @link = Link.find(params[:id])
    @comment = Comment.new
  end

  def new
    @link = Link.new
  end

  def create
    @link = current_user.links.new(link_params)

    if @link.save
      redirect_to @link, notice: 'Link was successfully created.'
    else
      flash.now[:alert] = @link.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def link_params
    params.require(:link).permit(:url, :title)
  end
end
