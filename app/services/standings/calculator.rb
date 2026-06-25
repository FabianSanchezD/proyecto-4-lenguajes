module Standings
  class Calculator
    def initialize(group)
      @group = group
    end

    def call
      standings = build_standings
      apply_results(standings)
      rank(standings.values)
    end

    def persist!
      call.each do |standing|
        standing.team.update_columns(
          points: standing.points,
          goals_for: standing.goals_for,
          goals_against: standing.goals_against
        )
      end
    end

    private

    attr_reader :group

    def build_standings
      group.teams.each_with_object({}) do |team, hash|
        hash[team.id] = TeamStanding.new(team)
      end
    end

    def apply_results(standings)
      group.group_matches.where(played: true).each do |match|
        home = standings[match.home_team_id]
        away = standings[match.away_team_id]
        next unless home && away

        home.register(scored: match.home_goals, conceded: match.away_goals)
        away.register(scored: match.away_goals, conceded: match.home_goals)
      end
    end

    def rank(standings)
      ordered = standings.sort_by do |s|
        [-s.points, -s.goal_difference, -s.goals_for, s.team.name]
      end
      ordered.each_with_index { |standing, index| standing.rank = index + 1 }
      ordered
    end
  end
end
