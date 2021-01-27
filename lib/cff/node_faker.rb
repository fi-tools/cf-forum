module Cff::NodeFaker
  include Cff::TemplateSetup
  include Cff::TemplateTestExtras

  def run_faker(n_fake_nodes, user, sub_user, general_user)
    # set up faker
    Faker::Config.random = Random.new(0)
    @faker_users = [user, sub_user, general_user]
    @faker_root = create_node nil, "Faker Root", @root, body: "All faker nodes will be created under this node."

    n_fake_nodes ||= 500
    n_fake_nodes = ENV["n_fake_nodes"]&.to_i || n_fake_nodes
    puts "n_fake_nodes set to #{n_fake_nodes}. set env var 'n_fake_nodes' to overwrite."
    self.run_faker_inner(n_fake_nodes)
  end

  def run_faker_inner(n_fake_nodes = nil)
    # default: 88k nodes with branching factor of 3. Approx uniformly max depth of 10
    n_topics_to_create = n_fake_nodes.nil? ? 88537 - 1 : n_fake_nodes
    branching_f = 3
    # a list of all the fake nodes we create and a var to track the next one we'll take
    queue = [@faker_root]
    # start child_c here to hit initial reset
    child_c = branching_f
    next_sample_index = 0
    Benchmark.bm do |m|
      m.report("creating #{n_topics_to_create} nodes\n") {
        parent = @faker_root
        n_topics_to_create.times.to_a.in_groups_of(90) do |i_chunk|
          ActiveRecord::Base.transaction do
            if queue.count < i_chunk.count
              i_chunk.each do |i|
                if child_c >= branching_f
                  parent = queue[next_sample_index]
                  next_sample_index += 1
                  child_c = 0
                end
                child_c += 1

                title = Faker::Lorem.sentence(word_count: 3, random_words_to_add: 4)
                body = Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4)
                queue << create_node(nil, title, parent, body: body, quiet: true)
              end
            else
              pairs = i_chunk.map do |i|
                if child_c >= branching_f
                  parent = queue[next_sample_index]
                  next_sample_index += 1
                  child_c = 0
                end
                child_c += 1
                title = Faker::Lorem.sentence(word_count: 3, random_words_to_add: 4)
                body = Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4)
                gen_node(nil, title, parent, body: body, quiet: true)
              end
              nodes = Node.find(Node.insert_all!(pairs.map { |p| p[0] }).map { |n| n["id"] })
              cvs = ContentVersion.insert_all!(pairs.map { |p| p[1] }.each_with_index.map { |cv, i| cv.merge(:node_id => nodes[i].id) })
              queue += nodes
            end
          end
          puts "created node #{i_chunk.last}/#{n_topics_to_create}"
        end
        NodeInheritedAuthzRead.refresh
      }
    end
  end
end
