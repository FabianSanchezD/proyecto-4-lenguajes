class Match < ApplicationRecord
  enum stage: {
    group_stage:   0,
    round_of_32:   1,
    round_of_16:   2,
    quarter_final: 3,
    semi_final:    4,
    third_place:   5,
    final:         6
  }

  STAGE_NAMES = {
    "group_stage"   => "Fase de Grupos",
    "round_of_32"   => "Dieciseisavos de Final",
    "round_of_16"   => "Octavos de Final",
    "quarter_final" => "Cuartos de Final",
    "semi_final"    => "Semifinales",
    "third_place"   => "Tercer Lugar",
    "final"         => "Final"
  }.freeze

  belongs_to :group, optional: true
  belongs_to :home_team, class_name: "Team", optional: true
  belongs_to :away_team, class_name: "Team", optional: true
  belongs_to :next_match, class_name: "Match", optional: true
  has_many :feeder_matches, class_name: "Match", foreign_key: :next_match_id, dependent: :nullify

  validates :home_goals, :away_goals, :home_penalties, :away_penalties,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :knockout, -> { where.not(stage: :group_stage) }

  def stage_name
    STAGE_NAMES[stage]
  end

  def knockout?
    !group_stage?
  end

  def draw?
    played? && home_goals == away_goals
  end

  def winner
    return nil unless played? && home_team && away_team

    if home_goals > away_goals
      home_team
    elsif away_goals > home_goals
      away_team
    elsif knockout? && home_penalties && away_penalties
      home_penalties > away_penalties ? home_team : away_team
    end
  end

  def loser
    return nil unless winner

    winner == home_team ? away_team : home_team
  end

  def teams_defined?
    home_team.present? && away_team.present?
  end

  def label
    "#{home_team&.name || 'Por definir'} vs #{away_team&.name || 'Por definir'}"
  end
end
