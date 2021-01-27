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
  include Cff::TemplateSetup
  include Cff::TemplateTestExtras
  include Cff::NodeFaker

  def initialize(n_fake_nodes: nil)
    self.create_test_admin_user
    self.create_test_admin_authors
    self.create_initial_forum
    self.add_to_group @admin, @g_subscribers

    self.create_test_posts_1
    self.setup_subscribers
    self.create_test_users
    self.create_test_subs_posts

    self.run_faker(88537 - 1, @admin, @sub_user, @general_user)
  end
end

SeedDatabase.new
