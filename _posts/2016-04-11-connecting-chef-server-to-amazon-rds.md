---
layout: post
title:  "Connecting Chef Server to Amazon RDS"
date:   "2016-04-11 14:58:50 -0500"
tags:
  - chef
  - aws
---

I previously wrote some notes on [Chef](https://www.chef.io/) Server's 
[external PostgreSQL support]({% post_url
2016-04-07-intro-to-external-postgresql-with-chef-server %}). I thought I'd 
also put together some technical details on using it with [Amazon 
RDS](https://aws.amazon.com/rds/).

The following assumes some familiarity with AWS, RDS, PostgreSQL, and Chef
Server.

## RDS

The Chef backend and frontend servers will all need access to the database. The
security groups will need to allow that access, port 5432 by default.

Chef opens a large number of connections to the database, so if you use a small
RDS instance type you may run out of connections with the default parameters.
If you run in to that (or just want to proactively avoid it) you'll need to
increase `max_connections` in your RDS Postgres parameter group.

The master user created with the instance is almost, but not quite, a Postgres
superuser. My preference is to reserve that account for administrative use and
create a second user to put in `chef-server.rb`.

Creating an RDS instance in the console will allow you to create a new
database. Leave that blank. Chef will create all of its structures during
initial setup.

Once the instance shows ready, you will need to create the slightly-less
privileged user for the Chef server to use. Log in to the RDS instance as the
master user:

{% highlight shell %}
psql -h yourrdsinstance.rds.amazonaws.com -U masteruser postgres
{% endhighlight %}

Run this at the psql prompt to create the new user:

{% highlight sql %}
CREATE USER "chef" WITH CREATEDB CREATEROLE PASSWORD 'secret';
{% endhighlight %}

Naturally, replace `chef` and `secret` with your preferred values (or don't,
I'm not your security admin). Exit from psql with `\q` or `ctrl-D`.

## Chef Server

Most of the `chef-server.rb` configuration is the same regardless of what
Postgres you use. There are a few additional parameters to configure the
external database, covered in the [Chef Server
documentation](https://docs.chef.io/chef_server.html). A summary:

{% highlight ruby %}
postgresql['db_superuser'] = 'chef' # Postgres user you created
postgresql['db_superuser_password'] = 'secret' # That user's password
postgresql['external'] = true # Must be set to true
postgresql['port'] = 5432 # Only required if you change the default port
postgresql['vip'] = 'yourrdsinstance.rds.amazonaws.com' # DNS entry from RDS
{% endhighlight %}

Once `chef-server.rb` is ready, run `chef-server-ctl reconfigure` and complete
the remaining configurations just as you would for the bundled Postgres.

## Un-configuring (cleansing)

Running `chef-server-ctl cleanse` works as expected. The external database
content will only be purged if you pass `--with-external`. If you don't include
it, `chef-server-ctl` will helpfully put a cleanup SQL script in the
`opscode-cleanse` backup directory and tell you about it.

## Backup and Restore

The recommended tool for backup and restore is [knife ec
backup](https://github.com/chef/knife-ec-backup). Recent versions of Chef
server put knife at `/opt/opscode/bin/knife`. You'll need to give it
`--sql-host yourrdsinstance.rds.amazonaws.com` to back up and restore.

You also need a working `knife` configuration and connectivity to your load
balancer (if you use one). You will need to either pass the `--server-url`
argument or put the `chef_server_url` setting in `.chef/knife.rb`. If you don't
disable SSL verification (which you shouldn't) you will also need to `knife ssl
fetch` the first time to set up the trust.

You can *probably* also do a regular PostgreSQL RDS backup along with saving a
copy of `/etc/opscode` and `/var/opt/opscode` somewhere secure (like a
locked-down S3 bucket), but you'd run the risk of filesystem and database being
out of sync if your environment is busy.

## Migrating to/from External PostgreSQL

There is no specific migration tool between the embedded Postgres and an
external database. You will need to use `knife ec` to backup from one and
restore to the other.

## Feedback?

Comments welcome. Best channels are probably Twitter
[@mkheironimus](https://twitter.com/mkheironimus) or email
[heironimus@gmail.com](mailto:heironimus@gmail.com).

