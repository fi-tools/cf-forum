WITH RECURSIVE "hierarchy" AS (
    SELECT id AS base_id,
        id
        0 AS distance
    FROM nodes
    UNION ALL
    SELECT "hierarchy"."base_id",
        "recursive".id,
        ("hierarchy"."distance" + 1)
    FROM "nodes" "recursive"
        INNER JOIN "hierarchy" ON "recursive"."parent_id" = "hierarchy"."id"
)
SELECT "hierarchy".*
FROM "hierarchy"
