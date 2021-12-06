ARG NODE_VERSION=16

FROM node:${NODE_VERSION}-alpine as build

RUN mkdir -p /usr/src/softhsm
WORKDIR /usr/src/softhsm

## Install Required Dependencies
RUN apk add --update --no-cache git sqlite sqlite-dev rsyslog g++ make autoconf automake libtool openssl-dev

# Fetch SoftHSM Modified Code
ARG SOFTHSM_GIT_REPO=https://github.com/Ticto/SoftHSMv2.git

# SoftHSM v2.2.0
ARG SOFTHSM_COMMIT_HASH=4c167c6f6ca8a5e9fdd65383e988993c248d837d

## Fetch Correct SoftHSM Code Commit
RUN git init && \
  git remote add origin $SOFTHSM_GIT_REPO && \
  git pull origin ecdh1-derive-kdf-hashing && \
  git checkout $SOFTHSM_COMMIT_HASH

## Compile & Install
RUN sh ./autogen.sh && ./configure --disable-gost && make && make install

## RUNTIME
FROM node:${NODE_VERSION}-alpine

COPY --from=build /usr/local/lib/softhsm /usr/local/lib/softhsm
COPY --from=build /usr/local/bin/softhsm2* /usr/local/bin/
COPY --from=build /var/lib/softhsm/tokens /var/lib/softhsm/tokens

RUN apk add --update --no-cache openssl-dev openssl

ENV SOFTHSM2_CONF /etc/softhsm2.conf
ADD softhsm2.conf /etc/softhsm2.conf

# Initiate SoftHSM Default if no other one is mounted, can be used for testing
COPY init_softhsm.sh /etc/
ENTRYPOINT ["/etc/init_softhsm.sh"]
