module Qualification
  class Selector
    BEST_THIRDS = 8

    def initialize(groups = Group.all.to_a)
      @groups = groups.sort_by(&:name)
    end

    def ready?
      @groups.size == 12 && @groups.all? { |g| group_complete?(g) }
    end

    def position_map
      @position_map ||= @groups.each_with_object({}) do |group, map|
        group.standings.first(3).each_with_index do |standing, index|
          map["#{index + 1}#{group.name}"] = standing.team
        end
      end
    end

    def best_third_groups
      thirds.first(BEST_THIRDS).map { |group, _standing| group.name }
    end

    def qualified
      best = best_third_groups
      list = []
      @groups.each do |group|
        standings = group.standings
        list << QualifiedTeam.new(team: standings[0].team, label: "1#{group.name}") if standings[0]
        list << QualifiedTeam.new(team: standings[1].team, label: "2#{group.name}") if standings[1]
      end
      @groups.each do |group|
        next unless best.include?(group.name)

        list << QualifiedTeam.new(team: group.standings[2].team, label: "3#{group.name}")
      end
      list
    end

    private

    def group_complete?(group)
      matches = group.group_matches
      matches.any? && matches.where(played: false).none?
    end

    def thirds
      pairs = @groups.filter_map do |group|
        standing = group.standings[2]
        [group, standing] if standing
      end
      pairs.sort_by do |_group, s|
        [-s.points, -s.goal_difference, -s.goals_for, s.team.name]
      end
    end
  end
end
