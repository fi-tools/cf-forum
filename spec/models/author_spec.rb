require 'rails_helper'

RSpec.describe Author do

  context 'by default' do

    subject(:author) { create(:author) }

    it 'is publicly avowed' do
      expect(subject).to be_public
    end
  end

  context 'when publicly avowed' do

    subject(:author) { create(:avowed_author) }
    let(:controlling_user_name) { author.user.username }

    context 'when formatting names' do

      subject(:author_name) { author.formatted_name }

      it 'is formatted with a prefix of u/ to signify that it is avowed by a user' do
        expect(subject).to start_with('u/')
      end

      it 'contains the controlling user name' do
        expect(subject).to include(controlling_user_name)
      end
    end
  end

  context 'when not publicly avowed' do

    subject(:author) { create(:disavowed_author) }
    let(:controlling_user_name) { author.user.username }

    it 'should not be publicly avowed' do
      expect(subject).to_not be_public
    end

    context 'when formatting names' do

      subject(:author_name) { author.formatted_name }

      it 'is formatted with a prefix of a/ to signify that it stands alone' do
        expect(subject).to start_with('a/')
      end

      it 'contains the author alias name' do
        expect(subject).to include(author_name)
      end

      it 'never contains the controlling user name' do
        expect(subject).to_not include(controlling_user_name)
      end
    end
  end
end
