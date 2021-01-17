SELECT m.*
FROM nodes n
LEFT JOIN LATERAL get_node_descendants(n.id) m ON true