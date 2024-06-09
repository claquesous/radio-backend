class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :streams
  has_many :requests
  has_many :ratings

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email

  before_create :set_initial_admin

  private
  def set_initial_admin
    self.admin = User.count==0
  end
end
