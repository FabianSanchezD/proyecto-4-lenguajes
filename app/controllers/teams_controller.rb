class TeamsController < ApplicationController
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.includes(:group).order("groups.name", "teams.name").references(:group)
  end

  def show
    @matches = @team.matches.includes(:home_team, :away_team)
  end

  def new
    @team = Team.new(group_id: params[:group_id])
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to @team, notice: "Selección registrada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: "Selección actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_path, notice: "Selección eliminada.", status: :see_other
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :group_id, :pot, :points, :goals_for, :goals_against)
  end
end
