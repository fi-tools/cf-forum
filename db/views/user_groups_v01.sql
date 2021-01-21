-- everyone is part of 'all'
SELECT u.id as user_id, 'all' as group_name FROM users u

UNION ALL

SELECT NULL, 'all'

UNION ALL

SELECT td.anchored_id as user_id, ut.tag as group_name
FROM system_tag_decls td
JOIN system_user_tags ut ON ut.id = td.target_id
JOIN users u ON td.anchored_id = u.id
WHERE 1=1
    AND td.anchored_type = 'User'
    AND td.target_type = 'UserTag'