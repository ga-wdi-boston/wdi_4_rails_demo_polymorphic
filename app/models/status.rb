class Status < ActiveRecord::Base
  belongs_to :user
  has_many :comments, as: :commentable
  validates :content, presence: true
end
