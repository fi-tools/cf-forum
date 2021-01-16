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
        @admin = User.create! :username => "admin", :hex_pw_hash => ""
        @admin_author = Author.create! :user => @admin, :name => "Admin", :public => true

        @root = create_node 0, "Critical Fallibilism Forum"
        @main = create_node 1, "Main", 0
        @meta = create_node 2, "Meta", 0
        # should it be called *detailed* instead?
        @details = create_node 3, "Details", 0
        @other = create_node 4, "Other", 0
    end

    def create_node id, title, parent=nil
        puts "create_node: #{id}, #{title}, #{parent}"
        node = Node.create! :id => id, :author => @admin_author
        if !parent.nil?
            node.parent = Node.find(parent)
            node.save!
        end 
        cv = ContentVersion.create! :id => id, :node => node, :title => title, :author => @admin_author
        node
    end
end

SeedDatabase.new
