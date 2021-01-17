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

----

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
