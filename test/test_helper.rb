ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# ActiveRecord::Base.connection.execute <<-SQL
#   SELECT pg_terminate_backend(pg_stat_activity.pid)
#   FROM pg_stat_activity
#   WHERE pg_stat_activity.datname = '#{Rails.configuration.database_configuration}' -- ← change this to your DB
#     AND pid <> pg_backend_pid();
#   SQL
# puts _, "thing"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # disable fixtures
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def gen_node(id, title, parent, body: nil, author: $admin_author, quiet: false)
    node_params = { :author => author }
    unless id.nil?
      node_params[:id] = id
    end
    unless parent.nil?
      node_params = node_params.merge(:parent_id => parent)
    end
    node = node_params
    cv = { :id => id, :title => title, :author => author, :body => body }
    return node_params, cv
  end

  def create_pair(pair)
    node_, cv_ = pair
    node = Node.create! **node_
    cv = ContentVersion.create! :node => node, **cv_
    node
  end

  def create_node(id, title, parent, body: nil, author: $admin_author, quiet: false)
    pair = gen_node id, title, parent, body: body, author: author, quiet: quiet
    create_pair pair
  end
end
