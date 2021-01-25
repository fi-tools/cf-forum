# for use with postgres+AGE (agensgraph extension)

class GraphHelper
  def parent(id)
    "(n:Node)-[:PARENT {id: #{id}}]->(p:Node)"
  end
end
