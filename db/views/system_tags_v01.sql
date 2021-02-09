SELECT td.id, td.tag as td_tag, td.anchored_type, td.anchored_id, ut.tag as ut_tag
FROM tag_decls as td
INNER JOIN user_tags as ut
ON td.target_id = ut.id
WHERE
  td.target_type = 'UserTag'
  AND ut.user_id IS NULL
  AND td.user_id IS NULL
