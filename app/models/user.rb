class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :rememberable, :validatable
  has_many :statuses, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :comments, dependent: :destroy
end
