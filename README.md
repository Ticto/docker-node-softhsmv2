# SoftHSM + Node Docker Image

Building blocks:

- Docker Node Alpine Images
- SoftHSMv2

## Building the image

```
export NODE_VERSION=16
docker build -t ticto/node-softhsmv2:${NODE_VERSION} --build-arg NODE_VERSION=${NODE_VERSION} .
```

