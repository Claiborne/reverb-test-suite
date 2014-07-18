Odin Functional and Acceptance Test Suite
=================


## How to run

Normal run:
```
rake odin SPEC_OPTS='--tag ~debug'
```

Debug run:
```
rake odin
```

Success-only specs:
```
rake odin SPEC_OPTS='--tag success'
```