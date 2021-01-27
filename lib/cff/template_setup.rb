module Cff::TemplateSetup
  def create_initial_forum
    @root = create_node 0, "Critical Fallibilism Forum", nil
    self.create_initial_view_tags
    self.create_some_other_tags
    self.set_root_tags @root
    self.create_initial_groups
    self.set_root_node_authz @root, @admin
    @main = create_node nil, "Main", @root
    @meta = create_node nil, "Meta", @root
    # should it be called *detailed* instead?
    @details = create_node nil, "Details", @root
    @other = create_node nil, "Other", @root
    [@main, @meta, @details, @other].each do |n|
      TagDecl.find_or_create_by! :anchored => n, :tag => Authz.writeChildren, :target => @g_all
    end
  end

  def set_root_tags(node)
    TagDecl.find_or_create_by! :anchored => node, :target => @t_root, :tag => :view, :user => nil
  end

  def set_root_node_authz(node, admin)
    TagDecl.find_or_create_by! :anchored => node, :target => @g_all, :tag => Authz::read
    TagDecl.find_or_create_by! :anchored => node, :target => @g_admins, :tag => Authz::write
    TagDecl.find_or_create_by! :anchored => admin, :target => @g_admins, :tag => Authz::userInGroup
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
    @g_admins = UserTag.find_or_create_by! :tag => :admins
    @g_subscribers = UserTag.find_or_create_by! :tag => :subscribers
  end

  def setup_subscribers
    # create subscribers area
    @subs_node = create_node nil, "SubsOnly", @root
    TagDecl.find_or_create_by! :anchored => @subs_node, :tag => Authz.read, :target => @g_subscribers
    TagDecl.find_or_create_by! :anchored => @subs_node, :tag => Authz.writeChildren, :target => @g_subscribers
  end

  def add_to_group(user, group)
    TagDecl.find_or_create_by! :anchored => user, :tag => Authz::userInGroup, :target => @g_subscribers
  end

  def add_timestamps(record)
    time = Time.now.utc
    record[:created_at] = time
    record[:updated_at] = time
  end

  def gen_user(username, email, pw)
    puts "Generating User: #{username} <#{email}> | pw: #{pw}"
    User.create! :username => username, :email => email, :password => pw
  end

  def gen_node(id, title, parent, body: nil, author: @admin_author, quiet: false)
    node_params = { :author_id => author.id }
    cv = { :title => title, :author_id => author.id, :body => body }
    unless id.nil?
      node_params[:id] = id
      cv[:id] = id
    end
    unless parent.nil?
      node_params = node_params.merge(:parent_id => parent.id)
    end
    add_timestamps(node_params)
    add_timestamps(cv)
    return node_params, cv
  end

  def create_node(id, title, parent, body: nil, author: @admin_author, quiet: false)
    pair = gen_node id, title, parent, body: body, author: author, quiet: quiet
    create_pair pair
  end

  def create_pair(pair)
    node_, cv_ = pair
    node = Node.create! **node_
    cv = ContentVersion.create! :node => node, **cv_
    node
  end
end
