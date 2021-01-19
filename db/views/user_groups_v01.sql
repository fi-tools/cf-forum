-- everyone is part of 'all'
--SELECT IFNULL(user_id,'null') || '|' || group_name as id, * from ( 
    SELECT u.id as user_id, 'all' as group_name FROM users u

    UNION ALL

    SELECT NULL, 'all'

    UNION ALL

    SELECT td.anchored_id as user_id, ut.tag as group_name
    FROM system_tag_decls td, users u
    JOIN system_user_tags ut ON td.target_id = ut.id
    WHERE 1
        AND td.anchored_type = 'User'
        AND td.target_type = 'UserTag'
        AND td.anchored_id = u.id
--)