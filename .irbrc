def runq q
  ActiveRecord::Base.connection.execute q
end

def r!
  reload!
end
