require 'rails_helper'

RSpec.describe Author do

  context 'when publicly avowed' do

    subject(:author) { create(:public_author) }

    context 'when formatting names' do

      subject( :author_name ) { author.formatted_name }

    end

  end

  context 'when not publicly avowed' do

    subject(:author) { create(:private_author) }
    let( :controlling_user_name ) { author.user.username }

    context 'when formatting names' do

      subject( :author_name ) { author.formatted_name }

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