class Person < ApplicationRecord
  has_many :credits, dependent: :destroy
  has_many :songs, -> { distinct }, through: :credits

  validates :name, presence: true

  # Finds or creates the person behind a credit. A MusicBrainz credit and a Discogs
  # credit for the same name merge into one person: a new external id claims the
  # oldest same-named person who doesn't have that kind of id yet.
  def self.for(name:, mb_artist_id: nil, discogs_id: nil)
    { mb_artist_id:, discogs_id: }.compact.each do |column, external|
      found = find_by(column => external)
      return found if found

      claimed = where("lower(name) = lower(?)", name).where(column => nil).order(:id).first
      if claimed
        claimed.update!(column => external)
        return claimed
      end
    end
    create!(name:, mb_artist_id:, discogs_id:)
  end
end
