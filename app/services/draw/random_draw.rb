module Draw
  class RandomDraw
    HOST_GROUPS = { "México" => "A", "Canadá" => "B", "Estados Unidos" => "D" }.freeze

    def call
      ActiveRecord::Base.transaction do
        Match.delete_all
        reset_teams
        groups = Group.order(:name).index_by(&:name)
        place_hosts(groups)
        (1..4).each { |pot| draw_pot(pot, groups) }
        Group.find_each { |group| Schedule::GroupFixtureGenerator.new(group).call }
      end
    end

    private

    def reset_teams
      Team.update_all(group_id: nil, points: 0, goals_for: 0, goals_against: 0)
    end

    def place_hosts(groups)
      HOST_GROUPS.each do |name, group_name|
        Team.find_by(name: name)&.update!(group: groups[group_name])
      end
    end

    def draw_pot(pot, groups)
      teams = Team.where(pot: pot, group_id: nil).to_a.shuffle
      available = groups.values.reject { |g| g.teams.where(pot: pot).exists? }.shuffle
      teams.zip(available).each do |team, group|
        team.update!(group: group) if group
      end
    end
  end
end
