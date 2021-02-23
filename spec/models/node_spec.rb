require 'rails_helper'

RSpec.describe Node do

  context 'by default' do

    subject(:node) { create(:node) }

    it 'is a root node' do
      expect(subject).to be_a_root_node
    end
  end

  context 'a root node' do

    subject(:root_node) { create(:node) }

    it 'is at depth zero' do
      expect(subject.depth).to eq(0)
    end

    context 'by default' do

      it 'has no children' do
        expect(subject.n_children).to eq(0)
      end
    end

    context 'with one child' do

      subject(:root_node_with_one_child) { create(:node_with_direct_children, direct_children_count: 1).reload }

      it 'has one direct child' do
        expect(subject.n_children).to eq(1)
      end

      it 'has one descendant' do
        expect(subject.n_descendants).to eq(1)
      end

      context 'when that child has one child' do

        subject(:root_node_with_one_child_when_that_child_has_a_child) { create(:node, parent: root_node_with_one_child.direct_children.first!).parent.parent.reload }

        it 'has only one direct child' do
          expect(subject.n_children).to eq(1)
        end

        it 'has two descendents' do
          expect(subject.n_descendants).to eq(2)
        end
      end
    end

    context 'with two children' do

      subject(:root_node_with_one_child){ create(:node_with_direct_children, direct_children_count: 2).reload }

      it 'has two direct children' do
        expect(subject.n_children).to eq(2)
      end

      it 'has two descendants' do
        expect(subject.n_descendants).to eq(2)
      end
    end
  end

  context 'when modifying child nodes' do

    subject(:root_node) { create(:node) }

    def add_child_node_to_node(node, depth: 1)
      Array.new(depth).inject(node) do |parent|
        create(:node, parent: parent)
      end
    end

    def updated_child_count_for(node)
      node.reload
      node.n_children
    end

    def updated_descendant_count_for(node)
      node.reload
      node.n_descendants
    end

    it 'reflects an addition in the count of direct child nodes' do
      expect { add_child_node_to_node(root_node) }.to change { updated_child_count_for(root_node) }.by(1)
    end

    it 'reflects an addition in the count of all descendant nodes' do
      expect { add_child_node_to_node(root_node, depth: 2) }.to change { updated_descendant_count_for(root_node) }.by(2)
    end

  end
end
