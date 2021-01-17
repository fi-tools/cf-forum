class AuthzTagDecl < TagDecl
end

=begin

This is the basis for tag-based authorization.
If a value is not set for authz_LEVEL_FIELD, then permissions should fall back to authz_LEVEL.

=end

AUTHZ = Hash.new
  [ :nop
    , :inherit
    , :node_inherit
    , :node_read
    , :node_read_title
    , :node_read_body
    , :node_read_children
    , :node_read_inherit
    , :node_write
    , :node_write_title
    , :node_write_body
    , :node_write_children
    , :node_write_inherit
    , :children_inherit
    , :children_read
    # , :children_read_title
    # , :children_read_body
    # , :children_read_children
    , :children_write
    # , :children_write_title
    # , :children_write_body
    # , :children_write_children
  ].each {|t| [t, t.to_s]}