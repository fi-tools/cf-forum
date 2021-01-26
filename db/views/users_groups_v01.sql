with raw_groups as (
    SELECT u.id as user_id,
        ut_tag
    FROM users u
        INNER JOIN system_tags st ON st.anchored_id = u.id
    WHERE st.anchored_type = 'User'
    UNION ALL
    SELECT u.id as user_id,
        'all' as ut_tag
    FROM users u
    UNION ALL
    SELECT NULL,
        'all'
)
SELECT user_id,
    array_agg(ut_tag) as groups
FROM raw_groups
GROUP BY user_id
