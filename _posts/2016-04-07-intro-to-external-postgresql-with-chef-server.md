---
layout: post
title:  "Intro to External PostgreSQL with Chef Server"
date:   "2016-04-07 19:23:20 -0500"
tags:
  - chef
---

Starting from version 12.2.0, released in September 2015, [Chef 
Server](https://www.chef.io/) supports running with an external 
[PostgreSQL](http://www.postgresql.org/) server instead of using the server 
embedded in the package. I've done some work at the day job on installing Chef 
with external PostgreSQL, so I decided that I should record my findings for 
posterity.

Starting with some background....

## What's embedded PostgreSQL?

The Chef server uses a relational database, PostgreSQL, to house some of its
configuration. The standard omnibus packages bundle a copy of Postgres, just
like they do Ruby, Erlang, RabbitMQ, etc. The first `chef-server-ctl
reconfigure` on a new install configures and populates Postgres, just like all
of the other bundled components. Most people probably only have to care about
the embedded PostgreSQL server when looking at backup/restore or server
migration.

## What's external PostgreSQL?

Recent versions of the Chef server can connect to a Postgres server running
somewhere else instead of using the server in the omnibus install. However,
*"external" probably doesn't mean what you think it means*. I think most people
with a background in infrastructure or application support would expect to set
up a new database and some users in an existing Postgres environment, point
Chef that way, and enjoy all the same benefits as the regular application
databases. At least that's what I expected when I initially read the
announcement.

That's not how it works.

You create a new user with either Postgres `SUPERUSER` access or the `CREATE
ROLE` and `CREATE DATABASE` privileges. That user (and its password) go in
`chef-server.rb`, and the initial `chef-server-ctl reconfigure` uses that
privileged account to create all of the users and databases that Chef needs -
just like it would have with its bundled server. If you purge the configuration
with a `chef-server-ctl cleanse`, there is an option to use that same
privileged user to drop all of the Chef users and databases.

## So does it work?

Of course it works! Early on some of the add-ons didn't support it, but I think
those have been updated now. Except for Chef Replication, which seems to have
disappeared from their download site altogether. The real question you should
ask is, "Should I use it?"

## OK, should I use it?

As with most things, the answer is a resounding, "it depends".

If you have a large enough environment that you want to split the database and
the backend server on to their own hardware just to handle the load, the
current external Postgres support will let you do that. When I last looked
there was no information on database tuning in the Chef documentation, so
you'll have to figure that out on your own. If you're that big you may already
have had to do some work on the embedded Postgres, and I'd expect most of the
lessons to carry over.

If you're running the server in [AWS](https://aws.amazon.com/), moving the
database to [RDS](https://aws.amazon.com/rds/) lets you delegate some of your
availability to Amazon. You would still need to use HA for the server, but if
you rely on RDS to take care of the database you might be able to justify
skipping HA at the Chef Server layer in favor of EBS snapshots (or just a quick
instance stop/start) without concern over database corruption.

However, I would not recommend using external Postgres in most Chef Server
environments. You typically would not use a shared database because Chef needs
too many privileges. An HA database cluster wouldn't provide any better
availability than doing HA for the Chef Server with the embedded database. The
embedded database also doesn't require much (if any) DBA work, so an external
database doesn't shift specialized work to your SME.

## Final words....

The Chef documentation covers the settings you need in `chef-server.rb` to use
an external database. If I can motivate myself I'll probably write a few notes
on doing it with RDS.

Are you using external PostgreSQL with Chef Server? Hit me up on Twitter
[@mkheironimus](https://twitter.com/mkheironimus) or email
[heironimus@gmail.com](mailto:heironimus@gmail.com) if you have comments. If
I'm paying attention and don't get distracted by a bright shiny object I might
even respond.

## Update 2016-04-11

I motivated myself and wrote my notes on [using Chef Server with Amazon RDS]({%
post_url 2016-04-11-connecting-chef-server-to-amazon-rds %}).

