class Song < ApplicationRecord
  include Rankable

  belongs_to :album, optional: true
  belongs_to :artist
  has_many :plays
  has_many :choosers, dependent: :destroy
  before_destroy :prevent_destroy
  default_scope { order(:sort) }

  validates :title, presence: true

  private

  def prevent_destroy
    errors.add(:base, "Songs cannot be deleted")
    throw :abort
  end

end
