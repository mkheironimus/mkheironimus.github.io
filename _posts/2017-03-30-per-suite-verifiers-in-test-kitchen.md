---
layout: post
title:  "Per-suite Verifiers in Test Kitchen"
date:   "2017-03-30 22:59:38 -0500"
tags:
  - chef
---

Overriding the default verifier for a [Test Kitchen](http://kitchen.ci/) suite
in `.kitchen.yml` is something that feels like it should be possible, but I
found it surprisingly difficult to locate an example of the syntax. So, here's
one (minimally) tested in kitchen 1.15.0:

```yaml
suites:
  - name: default
    run_list:
      - recipe[mycookbook]
    verifier:
      name: inspec
```

