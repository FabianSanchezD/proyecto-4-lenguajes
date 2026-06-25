module Schedule
  class GroupFixtureGenerator
    REQUIRED_TEAMS = 4

    def initialize(group)
      @group = group
    end

    def ready?
      @group.teams.count == REQUIRED_TEAMS
    end

    def call
      return false unless ready?
      return false if @group.group_matches.exists?

      @group.teams.to_a.combination(2).each do |home, away|
        Match.create!(stage: :group_stage, group: @group,
                      home_team: home, away_team: away, played: false)
      end
      true
    end
  end
end
