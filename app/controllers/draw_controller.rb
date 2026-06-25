class DrawController < ApplicationController
  def index
    @pots = Team.order(:name).group_by(&:pot)
    @groups = Group.includes(:teams).all
  end

  def create
    Draw::RandomDraw.new.call
    redirect_to draw_path, notice: "Sorteo realizado: grupos reorganizados por bombos."
  end
end
