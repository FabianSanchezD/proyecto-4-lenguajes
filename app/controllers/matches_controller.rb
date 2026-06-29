class MatchesController < ApplicationController
  before_action :set_match, only: %i[edit update]

  def index
    @group_matches = Match.where(stage: :group_stage)
                          .includes(:group, :home_team, :away_team)
                          .order("groups.name").references(:group)
    @knockout_matches = Match.knockout
                             .includes(:home_team, :away_team)
                             .order(:stage, :slot)
  end

  def edit; end

  def update
    recorder = MatchResult::Recorder.new(@match)
    saved = recorder.call(
      home_goals: result_params[:home_goals],
      away_goals: result_params[:away_goals],
      home_penalties: result_params[:home_penalties],
      away_penalties: result_params[:away_penalties]
    )
    if saved
      if @match.knockout?
        redirect_to knockout_path, notice: "Resultado registrado: #{@match.label} (#{@match.home_goals}-#{@match.away_goals})."
      else
        redirect_to matches_path, notice: "Resultado registrado: #{@match.label} (#{@match.home_goals}-#{@match.away_goals})."
      end
    else
      flash.now[:alert] = @match.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def result_params
    params.require(:match).permit(:home_goals, :away_goals, :home_penalties, :away_penalties)
  end
end
