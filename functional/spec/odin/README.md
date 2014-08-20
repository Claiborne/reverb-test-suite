Odin Functional and Acceptance Test Suite
=================

## Required software

2.0 >= Ruby >= 2.1.1 
```
sudo gem install rspec -v 2.14.0
```
```
sudo gem install rake bunny colorize rest-client json_pure --no-rdoc --no-ri
```

## How to run

Run against dev:
```
rake odin env=dev
```

Run against local:
```
rake odin env=local
```

Without debug output:
```
SPEC_OPTS='--tag ~debug'
```