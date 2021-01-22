class Node2 < Node
end

class Node3 < Node
  class << self
    def nodes_admin_can_read_with_parent_root
      nar = Arel::Table.new :nar
      Node.find_by_sql(Node.nodes_readable_by(User.find(1)).where(nar[:parent_id].eq 0))
    end
  end
end

class CffBench
  def initialize
    @n_runs = 10
    # @n_runs = 1

    @test = {
      Node3 => [[:nodes_admin_can_read_with_parent_root], []],
      Node => [[
        :get_nodes_readable_by,
      ], [User.find(1)]],
      Node.first => [[
        #:children_elegaint,
        #:children_elegaint_parent,
        :children_manual,
        #:descentands_elegaint,
        :descendants_via_nwc_simple,
        :descendants_via_nwc_optimized,
        # based on arel query
        :descendants_via_nwc2_arel,
        :descendants_via_arhq,
        :ancestors_via_arhq,
        :descendants_via_arel,
        :ancestors_via_arel,
      ], [User.find(1)]],
      Node2 => [[
        :all_node_system_tag_combos,
        :all_descendants_via_arel,
        :all_ancestors_via_arel,
      ], []],
      # User.where(id: 1).includes(:anchored_system_tags)[0]
      User.first => [[:user_groups, :groups, :groups2], []],
    }
  end

  def p(res)
    print "(#{res})"
  end

  def main
    puts "  >> BENCHMARKS - average of #{@n_runs} runs."
    Node.find(1)
    @test.keys.each do |kls|
      args = @test[kls][1]
      @test[kls][0].each do |method|
        res = nil
        m = Benchmark.realtime {
          @n_runs.times {
            ress = kls.public_send(method, *args).to_a
            res = ress.count
            # puts ress[0].to_json
          }
        }
        puts "%s %5.2f ms | result: %s" % [method.to_s.ljust(30), m / @n_runs * 1000, res.to_s]
      end
    end
  end
end

CffBench.new.main
