SELECT id, st.td_tag, st.ut_tag
FROM nodes
INNER JOIN system_tags as st
ON id = st.anchored_id
WHERE st.anchored_type = 'Node'
