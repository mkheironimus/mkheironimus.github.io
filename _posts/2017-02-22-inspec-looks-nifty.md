---
layout: post
title:  "InSpec Looks Nifty!"
date:   "2017-02-22 21:59:08 -0600"
tags:
  - chef
---

As a simple experiment, I converted some [Kitchen](http://kitchen.ci/) tests
for one of my (private) cookbooks from [ServerSpec](http://serverspec.org/) to
[InSpec](http://inspec.io/). None of them were all that complicated or
advanced, just basic verification of some files and links to dip my toe in the
InSpec waters. Moving those simple checks from ServerSpec really was as easy as
it looks from the InSpec [migration
guide](http://inspec.io/docs/reference/migration/).

One interesting note is that it's considerably faster to run my small handful
of tests through InSpec than it was with ServerSpec when I use generic Vagrant
boxes. Kitchen installs a number of Ruby gems to a temporary directory in the
test VM to support ServerSpec. InSpec doesn't need that. When I was doing lots
of cookbook development, I built custom Vagrant boxes and Docker images that
had most of what ServerSpec needed preinstalled so that I wouldn't have to wait
for gems to download over a slow network every time I did a full test run.
Having InSpec when I was doing that work would have saved me a headache.

I still would have needed a local Squid to speed up the package installs (and
to be nice to the mirrors). Squid didn't help with the gems because they were
downloading over SSL and I didn't care enough to get HTTPS content caching
working. Preinstalling the gems was probably easier anyway.

