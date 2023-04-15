# proto-station

This repository is intend for code generation from protobuf.  
The code generated here will be synchronized with the proto-terminal and put into a format that can be used as a library.

## dependency
* buf v1.7.0

## command

The dependent modules will be installed when `make gen` or `make gen-{foo}` is executed.

```shell script
# generate doc and code. 
$ make gen

# generate go code. 
$ make gen-go

# sync code to terminal. 
$ make sync

# run buf lint
$ make lint
```
