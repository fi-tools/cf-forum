SELECT nd.*, nr.user_id
FROM nodes_readables nr
INNER JOIN node_descendants nd
ON nr.node_id = nd.id
