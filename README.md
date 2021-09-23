# proto-station

This repository is intend for code generation from protobuf.  
The code generated here will be synchronized with the proto-terminal and put into a format that can be used as a library.

## dependency

* go v1.15
* protoc v3.14.0
* protoc-gen-doc v1.3.2
* protoc-gen-go v1.4.3
* protoc-gen-go-grpc v1.38.0
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

# sync code to terminal. 
$ make sync

# run buf lint
$ make lint
```

## Dependency

Need to clone these locally to use grpc-gateway.

https://github.com/googleapis/googleapis

- google/api/annotations.proto
- google/api/field_behaviour.proto
- google/api/http.proto
- google/api/httpbody.proto