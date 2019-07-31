# SoftHSM + Node Docker Image

Building blocks:

- Docker Node Alpine Images
- SoftHSMv2

## Building the image

```
NODE_VERSION=10.16.0 && docker build -t ticto/node-softhsmv2:${NODE_VERSION} --build-arg NODE_VERSION=${NODE_VERSION} .
```

## Performance Testing
