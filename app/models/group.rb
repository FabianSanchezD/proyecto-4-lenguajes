class Group < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :matches, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:name) }

  def standings
    Standings::Calculator.new(self).call
  end

  def group_matches
    matches.where(stage: :group_stage)
  end

  def to_s
    "Grupo #{name}"
  end
end
