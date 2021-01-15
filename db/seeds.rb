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
