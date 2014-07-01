class StatusesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def show
    @status = Status.find(params[:id])
    @comment = Comment.new
  end

  def new
    @status = Status.new
  end

  def create
    @status = current_user.statuses.new(status_params)

    if @status.save
      redirect_to @status, notice: 'Status was successfully created.'
    else
      flash.now[:alert] = @status.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def status_params
    params.require(:status).permit(:content)
  end
end
