=begin

This is the basis for tag-based authorization.
If a value is not set for authz_LEVEL_HERITABILITY_FIELD, then permissions should fall back to authz_LEVEL.

=end

class Authz
  class << self
    def inherit; :authz_inherit; end
    def read; :authz_read; end
    def write; :authz_write; end
    def readInherit; :authz_read_inherit; end
    def writeInherit; :authz_write_inherit; end
    def readNode; :authz_read_node; end
    def readNodeTitle; :authz_read_node_title; end
    def readNodeBody; :authz_read_node_body; end
    def readNodeChildren; :authz_read_node_children; end
    def readNodeInherit; :authz_read_node_inherit; end
    def writeNode; :authz_write_node; end
    def writeNodeTitle; :authz_write_node_title; end
    def writeNodeBody; :authz_write_node_body; end
    def writeNodeChildren; :authz_write_node_children; end
    def writeNodeInherit; :authz_write_node_inherit; end
    def readChildren; :authz_read_children; end
    def readChildrenInherit; :authz_read_children_inherit; end
    def childrenReadTitle; :authz_children_read_title; end
    def childrenReadBody; :authz_children_read_body; end
    def childrenReadChildren; :authz_children_read_children; end
    def writeChildren; :authz_write_children; end
    def writeChildrenInherit; :authz_write_children_inherit; end
    def childrenWriteTitle; :authz_children_write_title; end
    def childrenWriteBody; :authz_children_write_body; end
    def childrenWriteChildren; :authz_children_write_children; end
    def userInGroup; :authz_user_in_group; end
  end
end
