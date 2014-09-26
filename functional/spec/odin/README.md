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

Main suite:
```
rake odin env=dev SPEC_OPTS='--tag ~standard_success'
```

Supported environments:
```
rake odin env=dev
rake odin env=local
```

Without debug output:
```
SPEC_OPTS='--tag ~debug'
```