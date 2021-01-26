WITH node_all_ancestor_authz(base_id, id, groups) as (
    SELECT na.base_id, na.id, array_agg(nst.ut_tag) as groups
    FROM node_ancestors na
    INNER JOIN node_system_tags as nst
    ON na.id = nst.id
    WHERE nst.td_tag = 'authz_read'
),
closest_parent(base_id, closest_ancestor_id) as (
    SELECT base_id, MAXIMUM(id) as closest_ancestor_id
    FROM node_all_ancestor_authz
    GROUP BY base_id
),
node_to_permissions(id, groups) as (
    SELECT base_id, groups
    FROM node_all_ancestor_authz naaa
    JOIN closest_parent cp
    ON cp.base_id = naaa.base_id AND cp.closest_ancestor_id = naaa.id
)
select * from node_to_permissions
