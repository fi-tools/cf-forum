class G::Node
  def initialize
  end

  class << self
    def match(label, **opts)
      opts = opts.count > 0 ? " " + opts.to_json : ""

      return MatchNeedsRelationhip.new "(#{label.to_s}#{opts})"
    end

    def [](k, **opts)
      Match
    end
  end
end

class MatchNeedsRelationhip
  def initialize(existing)
    @existing = existing
  end
end
