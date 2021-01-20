SELECT n.id as node_id, td.tag as td_tag, ut.tag as ut_tag
FROM nodes n
JOIN system_tag_decls td ON td.anchored_id = n.id
JOIN system_user_tags ut ON td.target_id = ut.id
WHERE 1=1
    AND td.target_type = 'UserTag'
    AND td.anchored_type = 'Node'