module Knockout
  class Advancer
    def initialize(match)
      @match = match
    end

    def call
      return unless @match.knockout? && @match.played?

      advance_winner
      feed_third_place if @match.semi_final?
    end

    private

    def advance_winner
      next_match = @match.next_match
      winner = @match.winner
      return unless next_match && winner

      slot = @match.next_slot == "home" ? :home_team : :away_team
      next_match.update!(slot => winner)
    end

    def feed_third_place
      semis = Match.where(stage: :semi_final).order(:slot).to_a
      return unless semis.size == 2 && semis.all?(&:played?)

      third = Match.find_by(stage: :third_place)
      third&.update!(home_team: semis[0].loser, away_team: semis[1].loser)
    end
  end
end
