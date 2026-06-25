module Standings
  class TeamStanding
    attr_reader :team
    attr_accessor :played, :won, :drawn, :lost, :goals_for, :goals_against, :points, :rank

    def initialize(team)
      @team = team
      @played = @won = @drawn = @lost = 0
      @goals_for = @goals_against = @points = 0
      @rank = nil
    end

    def goal_difference
      goals_for - goals_against
    end

    def register(scored:, conceded:)
      @played += 1
      @goals_for += scored
      @goals_against += conceded

      if scored > conceded
        @won += 1
        @points += 3
      elsif scored == conceded
        @drawn += 1
        @points += 1
      else
        @lost += 1
      end
    end
  end
end
