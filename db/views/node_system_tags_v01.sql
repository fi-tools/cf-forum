SELECT nodes.id as node_id, st.id as st_id, st.td_tag, st.ut_tag
FROM nodes
INNER JOIN system_tags as st
ON nodes.id = st.anchored_id
WHERE st.anchored_type = 'Node'
