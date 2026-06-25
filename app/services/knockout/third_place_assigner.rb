module Knockout
  class ThirdPlaceAssigner
    SLOTS = {
      74 => %w[A B C D F],
      77 => %w[C D F G H],
      79 => %w[C E F H I],
      80 => %w[E H I J K],
      81 => %w[B E F I J],
      82 => %w[A E H I J],
      85 => %w[E F G I J],
      87 => %w[D E I J L]
    }.freeze

    def initialize(third_groups)
      @third_groups = third_groups
    end

    def call
      match = {}
      SLOTS.each_key { |slot| assign(slot, match, {}) }
      match.invert
    end

    private

    def assign(slot, match, visited)
      candidates(slot).each do |group|
        next if visited[group]

        visited[group] = true
        if !match.key?(group) || assign(match[group], match, visited)
          match[group] = slot
          return true
        end
      end
      false
    end

    def candidates(slot)
      SLOTS.fetch(slot) & @third_groups
    end
  end
end
