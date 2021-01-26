WITH RECURSIVE nwc(orig_id, id, parent_id, rel_depth) AS (
        SELECT id, id, parent_id, 0
        FROM nodes
        UNION ALL
        SELECT np.orig_id, n.id, n.parent_id, np.rel_depth + 1
        FROM nwc np, nodes n
        WHERE np.id = n.parent_id
) SELECT np.orig_id as base_node_id, np.rel_depth, n.* FROM nodes n, nwc np WHERE n.id = np.id