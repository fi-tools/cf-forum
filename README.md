# README

run:

* i think: `bundle install` for deps (you might need global rails, IDK)
* `bundle guard` to start guard
* then `rails s` (or `bundle rails s`?) to run the server 

## useful for testing migrations:

### my go-to while developing the schema

```
rails db:drop db:create db:migrate db:setup
```

or mb this is enough

```
rake db:reset db:migrate db:seed
```

and sometimes this, which seems reliable. the copying is for WSL

```
rm db/cff_dev.db ; rm db/schema.rb ; rake db:rollback VERSION=0 db:migrate ; rake db:migrate db:seed ; cp db/cff_dev.db /mnt/c/Users/xertrov/cff_dev.db
```

### create DB views

```
rails generate scenic:view view_tag_decls create db/views/view_tag_decls_v01.sql create 'db/migrate/[TIMESTAMP]_create_view_tag_decls.rb'
```

### other

* `rails db:migrate && dialog --yesno "Rollback?" 0 0 && rails db:rollback`
* `rails db:migrate && (until dialog --yesno "Rollback now?" 0 0; do echo 'use ctrl+c to never rollback'; sleep 3; done) && rails db:rollback`
* `rails db:reset && rails db:rollback && rails db:migrate && rails db:seed`

## load test fixtures into dev environment

**warning**: these are out of date; don't load them till updated

* `RAILS_ENV=development bin/rails db:fixtures:load`

## test seeds.db in test env (best way to test migrations?)

`rake RAILS_ENV=test db:reset db:migrate db:seed`

## show test.log output in diff terminal

`tail -f log/test.log`

(there are some benefits to doing this vs mixing logging w/ stdout)

## local postgres config -- note used atm

* `echo "create role cffdev with createdb login password 'hunter2';" | sudo -u postgres psql`
* then **NOT ON PRODUCTION - JUST FOR TEST** `echo "ALTER USER cffdev WITH SUPERUSER;" | sudo -u postgres psql` **NOT ON PRODUCTION - JUST FOR TEST**

you might need to run this first, but I think `create role` will create a user for you. 

* `sudo -u postgres createuser -s cffdev`

### cmd to test postgres in the `devpg` env

* `rm db/schema.rb ; rails db:environment:set RAILS_ENV=devpg ; RAILS_ENV=devpg rake db:drop db:create db:migrate db:setup`

## mysql local

```sql
CREATE USER 'cffdev'@'localhost' IDENTIFIED BY 'hunter2';
GRANT ALL PRIVILEGES ON * . * TO 'cffdev'@'localhost';
```

testing schemas:

```
rm db/schema.rb ; rails db:environment:set RAILS_ENV=devmysql ; RAILS_ENV=devmysql rake db:drop db:create db:migrate db:setup
```

## running dev server

* `rails s -e devpg --log-to-stdout`
* `bundle exec puma -t 5:5 -p ${PORT:-3000} -e devpg --log-to-stdout`

-----

## todo

* put authz on /admin
* implement create_child permission stuff
* **write tests**
* export everything (for migraiton and archive)
* import from export
* postgres via docker/compose/something -- with dev scripts ideally
  * note there are mb issues with docker for WSL

### future todos

* review efficiency of method of visibility/privacy enforcement?

-----

## incremental goals

### be capable of running discussion & issue tracking for dev of cf-forum on a dev instance of cf-forum

Important things: 

* create threads, nodes, etc
* view-node-as feature (view node as index)
* how to track stuff like done/not-done/etc?
* can we use a plugin system to do stuff like a project mgmt addon?
* rich-er text editing / markdown
* image upload / attachments
* what else??????

----

## feature notes

### file storage

* use s3 compatible api
* wasabi storage looks good
  * not AWS et al :thumbsup:
* give use pre-signed upload URL so it doesn't go through the server?
* use activestorage for tracking blobs
  * can this be used with s3 presigned urls?

### rich markdown editor thing

should we consider swapping over to using vue.js (or something) for UI? How soon? How hard to make that swap?

**todo** research

### other?

add other stuff if you can think of it and want to

----

## performance notes

* earlier: things looked grim for overhead with 25k nodes. queries^1 taking 2s (or 30s with postgres)
* latest: refactoring via arel with some restructuring meant postgres queries started taking like 200-300ms with 25k nodes.

[1]: the partiular queries involve complex joins and things to account for permissions and inheritance

----

some other performance notes from earlier are on <http://curi.us/2396#162>

### postgres? (out of date)

Here's a query from `rails s` logs

```
  Node Load (30684.2ms)  SELECT "nodes".* FROM "nodes" WHERE (id in (
      SELECT nwc.id FROM nodes_user_sees nus
      JOIN node_with_children nwc ON nwc.id = nus.base_node_id
      WHERE nwc.base_node_id = 0 AND rel_depth > 0 AND nus.user_id IS NULL
    ))
```

That query in sqlite and mysql takes < 2000ms, and usually 1000-1300ms. :/ Not sure what's going wrong there or if there's an easy way to solve via db schema or query structure. Could be e.g. lack of indexing or not using indexes.
