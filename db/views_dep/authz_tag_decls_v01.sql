-- the user_id here belongs to the person who created the tag declaration.
-- since were using tags created by the system, the user_id is null.

SELECT * FROM tag_decls WHERE tag LIKE 'authz_%' AND user_id IS NULL
