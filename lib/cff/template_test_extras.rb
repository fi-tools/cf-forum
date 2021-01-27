module Cff::TemplateTestExtras
  def test_setup_3_nodes
    create_test_admin_user(email: gen_random_email, :username => SecureRandom.hex(12))
    gen_user gen_random_string, gen_random_email, @test_pw

    @nodes = []
    @root = create_node(nil, "root", nil, author: @admin_author)
    @nodes << @root
    @nodes << create_node(nil, "reply1", @root, author: @admin_author)
    @nodes << create_node(nil, "reply2", @root, author: @admin_author)

    create_initial_groups
    set_root_node_authz @root, @admin

    NodeInheritedAuthzRead.refresh
  end

  def gen_random_email
    "#{SecureRandom.hex(12)}@xk.io"
  end

  def gen_random_string
    SecureRandom.hex(12)
  end

  def create_test_admin_user(**params)
    # pw = SecureRandom.hex(12)
    pw = "hunter2"
    @test_pw = pw
    admin_email = "asdf@xk.io"
    user_params = { :username => "admin", :email => admin_email, :password => pw }.merge(params)
    @admin = User.create! **user_params
    @admin_author = Author.find_or_create_by! :user => @admin, :name => user_params[:username].capitalize, :public => true

    Rails::logger.info "Admin | Email: #{user_params[:email]} | Password: #{pw}"
  end

  def create_test_admin_authors
    @author_anon = Author.find_or_create_by! :user => @admin, :name => "Anonymous", :public => false
    @author1 = Author.find_or_create_by! :user => @admin, :name => "name 1", :public => true
    @author2 = Author.find_or_create_by! :user => @admin, :name => "name 2 (secret)", :public => false
    @author3 = Author.find_or_create_by! :user => @admin, :name => "name 3", :public => true
    # @author4 = Author.find_or_create_by! :user => @admin, :name => "Name 3", :public => true
  end

  def create_test_posts_1
    @post1 = create_node nil, "Post 1", @main, body: "post 1 body", author: @author2
    @post2 = create_node nil, "Post 2", @main, body: "post 2 body", author: @author3

    @reply1 = create_node nil, "Reply 1st", @post2, body: "reply 1st level", author: @author1
    @reply2 = create_node nil, "Reply 2nd", @reply1, body: "reply 2nd level", author: @author2
    @reply3 = create_node nil, nil, @reply2, body: "reply 3rd level", author: @author1
    @reply1a = create_node nil, "Another Reply 1st L", @post2, body: "reply 1st level again", author: @author3
    @reply4 = create_node nil, nil, @reply3, body: "4th level repy body", author: @author3
    @reply5 = create_node nil, "5th level", @reply4, body: "body 5th", author: @author_anon
    @reply2a = create_node nil, "Click 'To Parent' to go back up", @reply1a, body: "It's at the bottom"
  end

  def create_some_other_tags
    ut = UserTag.find_or_create_by! :tag => :custom_label, :user => @admin
    TagDecl.find_or_create_by! :anchored => ut, :tag => :my_custom_tag, :target => ut, :user => @admin
    TagDecl.find_or_create_by! :anchored => @root, :tag => :my_custom_tag, :target => ut, :user => @admin
  end

  def create_test_users
    @sub_user = gen_user "subscriber", "cfsub@xk.io", @test_pw
    self.add_to_group @sub_user, @g_subscribers
    @general_user = gen_user "general-user", "cfgen@xk.io", @test_pw
  end

  def create_test_subs_posts
    @s1 = create_node nil, "subs only test", @subs_node, body: "only subs should see this"
    @s2a = create_node nil, "subs only reply", @s1, body: "only subs reply test"
    @s2b = create_node nil, nil, @s1, body: "yarp"
  end
end
