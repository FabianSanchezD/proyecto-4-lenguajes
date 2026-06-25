class DashboardController < ApplicationController
  def index
    @groups = Group.includes(:teams).all
    @total_teams = Team.count
    @group_matches_played = Match.where(stage: :group_stage, played: true).count
    @group_matches_total = Match.where(stage: :group_stage).count
    @knockout_built = Match.knockout.exists?
    @podium = Knockout::Podium.new.call
  end
end
