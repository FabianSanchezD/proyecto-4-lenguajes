class KnockoutController < ApplicationController
  STAGES = %i[round_of_32 round_of_16 quarter_final semi_final final third_place].freeze

  def index
    @ready = Qualification::Selector.new.ready?
    @rounds = STAGES.index_with do |stage|
      Match.where(stage: stage).includes(:home_team, :away_team).order(:slot)
    end
    @podium = Knockout::Podium.new.call
  end

  def qualification
    selector = Qualification::Selector.new
    @ready = selector.ready?
    @qualified = @ready ? selector.qualified : []
  end

  def build
    if Knockout::BracketBuilder.new.call
      redirect_to knockout_path, notice: "Bracket de eliminación directa generado."
    else
      redirect_to knockout_path, alert: "La fase de grupos aún no está completa."
    end
  end
end
