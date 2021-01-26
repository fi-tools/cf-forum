SELECT nar.base_node_id, user_id
FROM node_authz_reads nar
JOIN user_groups ug ON ug.group_name = nar.group_name