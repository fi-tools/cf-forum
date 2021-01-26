SELECT u.id as user_id, array_agg(ut.tag) as groups
FROM users u
INNER JOIN system_tags st
ON st.anchored_id = u.id
WHERE st.anchored_type = 'User'
