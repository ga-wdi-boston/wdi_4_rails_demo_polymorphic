class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    like = Like.new
    like.user = current_user
    like.likeable = likeable

    like.save!
    redirect_to :back
  end

  def destroy
    Like.find(params[:id]).destroy!
    redirect_to :back
  end

  private

  def likeable
    likeable_type.camelize.constantize.find(likeable_id)
  end

  def likeable_id
    params["#{likeable_type}_id"]
  end

  def likeable_type
    %w(status link).detect{ |type| params["#{type}_id"].present? }
  end
end
