class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy generate_fixtures]

  def index
    @groups = Group.includes(:teams).all
  end

  def show
    @standings = @group.standings
    @matches = @group.group_matches.includes(:home_team, :away_team)
  end

  def new
    @group = Group.new
  end

  def edit; end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to @group, notice: "Grupo creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: "Grupo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "Grupo eliminado.", status: :see_other
  end

  def generate_fixtures
    if Schedule::GroupFixtureGenerator.new(@group).call
      redirect_to @group, notice: "Calendario generado (6 partidos)."
    else
      redirect_to @group, alert: "Se requieren 4 equipos y que no existan partidos previos."
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
