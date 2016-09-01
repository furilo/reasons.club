class Issue < ActiveRecord::Base

  has_many :reasons
  has_many :most_voted_reasons, -> { order('reasons.votes_positive DESC') }, class_name: 'Reason'
  # Issue.includes(:most_voted_reasons)

  belongs_to :user

  extend FriendlyId
  friendly_id :title, use: :slugged

  include PublicActivity::Common

  validates :title, presence: true, length: { minimum: 10 }
  after_create :subscribe, :track_activity

  scope :public_issues, -> { where(privacy_public: 2) }
  scope :featured, -> { where(featured: 1) }

  private

  def track_activity
    self.create_activity action: 'create', owner: self.user
  end

  def subscribe
    Subscription.subscribe_to self.user, self
  end

  def votes_for
    votes = 0
    self.reasons.for.find_each do |reason|
      votes     += reason.votes_for.size
    end
    votes
  end

  def votes_against
    votes = 0
    self.reasons.against.find_each do |reason|
      votes += reason.votes_for.size
    end
    votes
  end
end
