class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :rememberable, :validatable
  has_many :statuses, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  def like_for(likeable)
    likeable.likes.find_by(user_id: id)
  end
end
