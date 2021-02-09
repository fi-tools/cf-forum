SELECT niar.node_id, ug.user_id --, niar.groups as node_groups, ug.groups as user_groups
FROM node_inherited_authz_reads niar
INNER JOIN users_groups ug
ON niar.groups && ug.groups
