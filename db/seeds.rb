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
    @admin_author = Author.create! :user => @admin, :name => "Admin", :public => true
    @author_anon = Author.create! :user => @admin, :name => "Anonymous", :public => false
    # @author_blank = Author.create! :user => @admin, :name => "", :public => false

    @author1 = Author.create! :user => @admin, :name => "name 1", :public => true
    @author2 = Author.create! :user => @admin, :name => "name 2 (secret)", :public => false
    @author3 = Author.create! :user => @admin, :name => "name 3", :public => true
    # @author4 = Author.create! :user => @admin, :name => "Name 3", :public => true

    @root = create_node 0, "Critical Fallibilism Forum", nil
    self.create_initial_view_tags
    self.set_root_tags @root
    slef.set_root_permissions @root

    @main = create_node 1, "Main", @root.id
    @meta = create_node 2, "Meta", @root.id
    # should it be called *detailed* instead?
    @details = create_node 3, "Details", @root.id
    @other = create_node 4, "Other", @root.id

    @post1 = create_node nil, "Post 1", @main.id, body: "post 1 body", author: @author2
    @post2 = create_node nil, "Post 2", @main.id, body: "post 2 body", author: @author3

    @reply1 = create_node nil, "Reply 1st", @post2.id, body: "reply 1st level", author: @author1
    @reply2 = create_node nil, "Reply 2nd", @reply1.id, body: "reply 2nd level", author: @author2
    @reply3 = create_node nil, nil, @reply2.id, body: "reply 3rd level", author: @author1
    @reply1a = create_node nil, "Another Reply 1st L", @post2.id, body: "reply 1st level again", author: @author3
    @reply4 = create_node nil, nil, @reply3.id, body: "4th level repy body", author: @author3
    @reply5 = create_node nil, "5th level", @reply4.id, body: "body 5th", author: @author_anon
    @reply2a = create_node nil, "Click 'To Parent' to go back up", @reply1a.id, body: "It's at the bottom"

    puts "Admin | Email: #{admin_email} | Password: #{pw}"
    gen_user "subscriber", "cfsub@xk.io", pw
    gen_user "general-user", "cfsub@xk.io", pw
  end

  def gen_user(username, email, pw)
    puts "Generating User: #{username} <#{email}> | pw: #{pw}"
    Users.create! :username => username, :email => email, :password => pw
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
    TagDecl.create! :anchored => node, :target => @t_root, :tag => :view, :user => nil
  end

  def set_root_permissions(node, user)
    TagDecl.create! :anchored => node, :target => user, :tag => AUTHZ

  def create_initial_view_tags
    @t_root = UserTag.create! :tag => :root
    @t_index = UserTag.create! :tag => :index
    @t_topic = UserTag.create! :tag => :topic
    @t_comment = UserTag.create! :tag => :comment
  end

  #   def create_tag(tag)
  #   end
end

SeedDatabase.new
