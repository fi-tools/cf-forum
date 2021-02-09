SELECT nd.*, nr.user_id
FROM nodes_readables nr
INNER JOIN node_descendants_incrs nd
ON nr.node_id = nd.node_id
