WITH all_node_authz_read AS (
    SELECT nwa.base_node_id, nwa.rel_height, nstc.node_id, nstc.ut_tag as group_name
FROM node_with_ancestors nwa
JOIN node_system_tag_combos as nstc ON nstc.node_id = nwa.id
WHERE nstc.td_tag = 'authz_read'
),
rel_heights AS (
    SELECT base_node_id, MIN(rel_height) AS height
    FROM all_node_authz_read
    GROUP BY base_node_id
)
SELECT anar.base_node_id, anar.rel_height, anar.node_id as authz_node_id, anar.group_name
FROM all_node_authz_read anar
JOIN rel_heights rh ON anar.base_node_id = rh.base_node_id
WHERE anar.rel_height = rh.height