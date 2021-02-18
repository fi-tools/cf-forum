require 'rails_helper'

RSpec.describe Node do

  context 'by default' do

    subject(:node){ create(:node) }

    it 'is a root node' do
      expect(subject).to be_a_root_node
    end
  end

  context 'a root node' do

    subject(:root_node){ create(:node) }

    it 'is at depth zero' do
      expect(subject.depth).to eq(0)
    end

    it 'has no children' do
      expect(subject.n_children).to eq(0)
    end


    context 'with one child' do

      subject(:root_node_with_one_child){ create(:node_with_direct_children, direct_children_count: 1).reload }

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
end