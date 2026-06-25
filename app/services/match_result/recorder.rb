module MatchResult
  class Recorder
    def initialize(match)
      @match = match
    end

    def call(home_goals:, away_goals:, home_penalties: nil, away_penalties: nil)
      @match.assign_attributes(
        home_goals: normalize(home_goals),
        away_goals: normalize(away_goals),
        home_penalties: normalize(home_penalties),
        away_penalties: normalize(away_penalties),
        played: true
      )

      validate_business_rules
      return false if @match.errors.any?

      ActiveRecord::Base.transaction do
        @match.save!
        apply_side_effects
      end
      true
    end

    private

    def normalize(value)
      return nil if value.nil? || value.to_s.strip.empty?

      value.to_i
    end

    def validate_business_rules
      unless @match.teams_defined?
        @match.errors.add(:base, "Ambos equipos deben estar definidos antes de registrar el resultado.")
        return
      end

      if @match.home_goals.nil? || @match.away_goals.nil?
        @match.errors.add(:base, "Debe ingresar los goles de ambos equipos.")
        return
      end

      validate_knockout_tiebreak if @match.knockout?
    end

    def validate_knockout_tiebreak
      return unless @match.home_goals == @match.away_goals

      if @match.home_penalties.nil? || @match.away_penalties.nil?
        @match.errors.add(:base, "Empate en tiempo reglamentario: debe registrar los penales.")
      elsif @match.home_penalties == @match.away_penalties
        @match.errors.add(:base, "Los penales no pueden quedar empatados; debe haber un ganador.")
      end
    end

    def apply_side_effects
      if @match.group_stage?
        Standings::Calculator.new(@match.group).persist!
        Knockout::BracketBuilder.new.call
      else
        Knockout::Advancer.new(@match).call
      end
    end
  end
end
