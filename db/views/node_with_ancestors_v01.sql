WITH RECURSIVE nwa(orig_id, id, parent_id, rel_height) AS (
        SELECT id, id, parent_id, 0
        FROM nodes
        UNION ALL
        SELECT np.orig_id, n.id, n.parent_id, np.rel_height + 1
        FROM nwa np, nodes n
        WHERE np.parent_id = n.id
) SELECT np.orig_id as base_node_id, np.rel_height, n.* FROM nodes n, nwa np WHERE n.id = np.id