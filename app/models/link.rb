class Link < ActiveRecord::Base
  belongs_to :user
  validates :url, :title, presence: true
  validates :url, format: { with: /\Ahttp/ }
end
