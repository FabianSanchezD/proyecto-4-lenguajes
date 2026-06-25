module Knockout
  class Podium
    Result = Struct.new(:champion, :runner_up, :third_place, keyword_init: true)

    def call
      final = Match.find_by(stage: :final)
      third = Match.find_by(stage: :third_place)

      Result.new(
        champion: final&.played? ? final.winner : nil,
        runner_up: final&.played? ? final.loser : nil,
        third_place: third&.played? ? third.winner : nil
      )
    end
  end
end
