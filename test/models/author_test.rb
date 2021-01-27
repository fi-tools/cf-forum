require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "name formatting" do
    user, a1 = gen_test_user_and_author
    assert a1.formatted_name == "a/#{a1.name}"

    assert Author.create!(:name => "asdf", :public => false, :user_id => user.id).formatted_name == "a/asdf"
    assert Author.create!(:public => true, :user_id => user.id).formatted_name == "u/#{user.username}"
  end
end
