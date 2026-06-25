module Knockout
  class BracketBuilder
    ROUND_OF_32 = {
      73 => %w[2A 2B], 74 => ["1E", "3"], 75 => %w[1F 2C], 76 => %w[1C 2F],
      77 => ["1I", "3"], 78 => %w[2E 2I], 79 => ["1A", "3"], 80 => ["1L", "3"],
      81 => ["1D", "3"], 82 => ["1G", "3"], 83 => %w[2K 2L], 84 => %w[1H 2J],
      85 => ["1B", "3"], 86 => %w[1J 2H], 87 => ["1K", "3"], 88 => %w[2D 2G]
    }.freeze

    PARENTS = {
      89 => [74, 77], 90 => [73, 75], 91 => [76, 78], 92 => [79, 80],
      93 => [83, 84], 94 => [81, 82], 95 => [86, 88], 96 => [85, 87],
      97 => [89, 90], 98 => [93, 94], 99 => [91, 92], 100 => [95, 96],
      101 => [97, 98], 102 => [99, 100],
      104 => [101, 102]
    }.freeze

    SLOT_ORDER = {
      74 => 1, 77 => 2, 73 => 3, 75 => 4, 83 => 5, 84 => 6, 81 => 7, 82 => 8,
      76 => 9, 78 => 10, 79 => 11, 80 => 12, 86 => 13, 88 => 14, 85 => 15, 87 => 16,
      89 => 1, 90 => 2, 93 => 3, 94 => 4, 91 => 5, 92 => 6, 95 => 7, 96 => 8,
      97 => 1, 98 => 2, 99 => 3, 100 => 4,
      101 => 1, 102 => 2, 103 => 1, 104 => 1
    }.freeze

    STAGE_OF = lambda do |number|
      case number
      when 73..88   then :round_of_32
      when 89..96   then :round_of_16
      when 97..100  then :quarter_final
      when 101..102 then :semi_final
      when 103      then :third_place
      when 104      then :final
      end
    end

    def initialize(groups = Group.all.to_a)
      @selector = Qualification::Selector.new(groups)
    end

    def ready?
      @selector.ready?
    end

    def call
      return false unless ready?

      ActiveRecord::Base.transaction do
        Match.knockout.delete_all
        matches = create_matches
        link_parents(matches)
        seed_round_of_32(matches)
      end
      true
    end

    private

    def create_matches
      (73..104).to_a.index_with do |number|
        Match.create!(stage: STAGE_OF.call(number), slot: SLOT_ORDER.fetch(number), played: false)
      end
    end

    def link_parents(matches)
      PARENTS.each do |parent, (home_feeder, away_feeder)|
        matches[home_feeder].update!(next_match: matches[parent], next_slot: "home")
        matches[away_feeder].update!(next_match: matches[parent], next_slot: "away")
      end
    end

    def seed_round_of_32(matches)
      positions = @selector.position_map
      third_by_slot = ThirdPlaceAssigner.new(@selector.best_third_groups).call

      ROUND_OF_32.each do |number, (home_code, away_code)|
        matches[number].update!(
          home_team: team_for(home_code, number, positions, third_by_slot),
          away_team: team_for(away_code, number, positions, third_by_slot)
        )
      end
    end

    def team_for(code, slot_number, positions, third_by_slot)
      if code == "3"
        positions["3#{third_by_slot[slot_number]}"]
      else
        positions[code]
      end
    end
  end
end
