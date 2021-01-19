require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "name formatting" do
    id = User.first.id
    a1 = Author.create! :name => "n", :public => true, :user_id => id
    assert a1.formatted_name == "a/n"

    assert Author.create!(:name => "asdf", :public => false, :user_id => id).formatted_name == "a/asdf"
    assert Author.create!(:public => true, :user_id => id).formatted_name == "u/admin"
  end
end
