# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# execute "insert into content_versions (id, title, node_id) values (0, 'Critical Fallibilism Forum', 0)"
# execute "insert into nodes (id, content_version_id) values (0, 0)"

# execute "insert into content_versions (id, title, node_id) values (1, 'Main', 1)"
# execute "insert into nodes (id, content_version_id) values (1, 1)"

# cv_root = ContentVersion.create :id => 0, :title => "Critical Fallibilism Forum", :body => "", :node_id => 0
# cv_root.save
# root = Node.create :id => 0, :content_version_id => 0
# root.save
# puts root

# ContentVersion.create :id => 1, :title => "Main", :body => "", :node_id => 1
# Node.create :id => 1, :content_version_id => 1

# execute "insert into content_versions (id, title, created_at, updated_at) values (0, 'Critical Fallibilism Forum', 0, 0)"
# execute "insert into nodes (id, content_version_id, created_at, updated_at) values (0, 0, 0, 0)"
# execute "update content_versions set node_id = 0 where id = 0"

# execute "insert into content_versions (id, title, created_at, updated_at) values (1, 'Main', 0, 0)"
# execute "insert into nodes (id, content_version_id, parent_id, created_at, updated_at) values (1, 1, 0, 0, 0)"
# execute "update content_versions set node_id = 1 where id = 1"

class SeedDatabase
  def initialize
    # pw = SecureRandom.hex(12)
    pw = "hunter2"
    admin_email = "asdf@xk.io"
    @admin = User.create! :username => "admin", :email => admin_email, :password => pw
    @admin_author = Author.find_or_create_by! :user => @admin, :name => "Admin", :public => true
    @author_anon = Author.find_or_create_by! :user => @admin, :name => "Anonymous", :public => false
    # @author_blank = Author.find_or_create_by! :user => @admin, :name => "", :public => false

    @author1 = Author.find_or_create_by! :user => @admin, :name => "name 1", :public => true
    @author2 = Author.find_or_create_by! :user => @admin, :name => "name 2 (secret)", :public => false
    @author3 = Author.find_or_create_by! :user => @admin, :name => "name 3", :public => true
    # @author4 = Author.find_or_create_by! :user => @admin, :name => "Name 3", :public => true

    @root = create_node 0, "Critical Fallibilism Forum", nil
    self.create_initial_view_tags
    self.create_some_other_tags
    self.set_root_tags @root
    self.create_initial_groups
    self.add_to_group @admin, @g_subscribers
    self.set_root_node_authz @root, @admin

    @main = create_node nil, "Main", @root.id
    @meta = create_node nil, "Meta", @root.id
    # should it be called *detailed* instead?
    @details = create_node nil, "Details", @root.id
    @other = create_node nil, "Other", @root.id

    [@main, @meta, @details, @other].each do |n|
      TagDecl.find_or_create_by! :anchored => n, :tag => Authz.writeChildren, :target => @g_all
    end

    @post1 = create_node nil, "Post 1", @main.id, body: "post 1 body", author: @author2
    @post2 = create_node nil, "Post 2", @main.id, body: "post 2 body", author: @author3

    @reply1 = create_node nil, "Reply 1st", @post2.id, body: "reply 1st level", author: @author1
    @reply2 = create_node nil, "Reply 2nd", @reply1.id, body: "reply 2nd level", author: @author2
    @reply3 = create_node nil, nil, @reply2.id, body: "reply 3rd level", author: @author1
    @reply1a = create_node nil, "Another Reply 1st L", @post2.id, body: "reply 1st level again", author: @author3
    @reply4 = create_node nil, nil, @reply3.id, body: "4th level repy body", author: @author3
    @reply5 = create_node nil, "5th level", @reply4.id, body: "body 5th", author: @author_anon
    @reply2a = create_node nil, "Click 'To Parent' to go back up", @reply1a.id, body: "It's at the bottom"

    # create subscribers area
    @subs_node = create_node nil, "SubsOnly", @root.id
    TagDecl.find_or_create_by! :anchored => @subs_node, :tag => Authz.read, :target => @g_subscribers
    TagDecl.find_or_create_by! :anchored => @subs_node, :tag => Authz.read, :target => @g_admins
    TagDecl.find_or_create_by! :anchored => @subs_node, :tag => Authz.writeChildren, :target => @g_subscribers

    puts "Admin | Email: #{admin_email} | Password: #{pw}"
    sub_user = gen_user "subscriber", "cfsub@xk.io", pw
    self.add_to_group sub_user, @g_subscribers
    general_user = gen_user "general-user", "cfgen@xk.io", pw

    @s1 = create_node nil, "subs only test", @subs_node.id, body: "only subs should see this"
    @s2a = create_node nil, "subs only reply", @s1.id, body: "only subs reply test"
    @s2b = create_node nil, nil, @s1.id, body: "yarp"

  

    # set up faker
    Faker::Config.random = Random.new(0)
    @faker_users = [@admin, sub_user, general_user]
    @faker_root = create_node nil, "Faker Root", @root.id, body: "All faker nodes will be created under this node."

    self.run_faker

  end

  def gen_user(username, email, pw)
    puts "Generating User: #{username} <#{email}> | pw: #{pw}"
    User.create! :username => username, :email => email, :password => pw
  end

  def create_node(id, title, parent, body: nil, author: @admin_author)
    puts "create_node: #{id}, #{title}, #{parent}, #{body}"
    node_params = { :author => author }
    if !id.nil?
      node_params[:id] = id
    end
    if !parent.nil?
      node_params = node_params.merge(:parent_id => parent)
    end
    puts "creating node"
    node = Node.create! **node_params
    puts "node.parent: #{node.parent&.id}"
    cv = ContentVersion.create! :id => id, :node => node, :title => title, :author => author, :body => body
    node
  end

  def set_root_tags(node)
    TagDecl.find_or_create_by! :anchored => node, :target => @t_root, :tag => :view, :user => nil
  end

  def set_root_node_authz(node, admin)
    TagDecl.find_or_create_by! :anchored => node, :target => @g_all, :tag => Authz::read
    # TagDecl.find_or_create_by! :anchored => node, :target => @g_admins, :tag => Authz::write
    # TagDecl.find_or_create_by! :anchored => admin, :target => @g_admins, :tag => Authz::userInGroup
    # TagDecl.find_or_create_by! :anchored => @g_admins, :target => @g_subscribers, :tag => :group_in_group
  end

  def create_initial_view_tags
    @t_root = UserTag.find_or_create_by! :tag => :root
    @t_index = UserTag.find_or_create_by! :tag => :index
    @t_topic = UserTag.find_or_create_by! :tag => :topic
    @t_comment = UserTag.find_or_create_by! :tag => :comment
  end

  def create_initial_groups
    @g_all = UserTag.find_or_create_by! :tag => :all
    @g_subscribers = UserTag.find_or_create_by! :tag => :subscribers
    @g_admins = UserTag.find_or_create_by! :tag => :admins
  end

  def create_some_other_tags
    ut = UserTag.find_or_create_by! :tag => :custom_label, :user => @admin
    TagDecl.find_or_create_by! :anchored => ut, :tag => :my_custom_tag, :target => ut, :user => @admin
  end

  def add_to_group(user, group)
    TagDecl.find_or_create_by! :anchored => user, :tag => Authz::userInGroup, :target => @g_subscribers
  end

  def run_faker
    n_topics_to_create = 250
    node_choices = [@faker_root]
    puts node_choices

    n_topics_to_create.times do |i|
      parent = node_choices.sample
      title = Faker::Lorem.sentence(word_count: 3, random_words_to_add: 4)
      body = Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4)
      node_choices << create_node(nil, title, parent.id, body: body)
    end 
  end

  #   def create_tag(tag)
  #   end
end

SeedDatabase.new
