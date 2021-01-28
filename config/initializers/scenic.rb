Scenic.configure do |config|
  # these are commented bc we need them if using sqlite or mysql, but they cause errors sometimes when this file is run without the db being initialized first
  # if ["SQLite"].include? ActiveRecord::Base.connection.adapter_name
  #   #Rails.env.development? || Rails.env.test? || Rails.env[0,3] == "dev"
  #   config.database = Scenic::Adapters::Sqlite.new
  # end

  # # 'SQLite', 'PostgreSQL',
  # if ["Mysql2"].include? ActiveRecord::Base.connection.adapter_name
  #   config.database = Scenic::Adapters::Mysql.new
  # end
end
