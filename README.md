# proto-station

This repository is intend for code generation from protobuf.
The code generated here will be synchronized with the proto-terminal and put into a format that can be used as a library.

## dependency

* go v1.15
* protoc v3.14.0
* protoc-gen-doc v1.3.2
* protoc-gen-go v1.4.3
* buf v0.33.0

## command

The dependent modules will be installed when `make gen` or `make gen foo` is executed.

```shell script
# generate doc and code. 
$ make gen

# generate doc. 
$ make gen-doc

# generate go code. 
$ make gen-go

# run buf lint
$ make lint
```