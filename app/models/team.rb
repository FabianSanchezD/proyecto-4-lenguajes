class Team < ApplicationRecord
  belongs_to :group, optional: true

  has_many :home_matches, class_name: "Match", foreign_key: :home_team_id, dependent: :nullify
  has_many :away_matches, class_name: "Match", foreign_key: :away_team_id, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :points, :goals_for, :goals_against,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pot, inclusion: { in: 1..4 }, allow_nil: true

  def goal_difference
    goals_for - goals_against
  end

  def matches
    Match.where("home_team_id = :id OR away_team_id = :id", id: id)
  end

  def to_s
    name
  end
end
