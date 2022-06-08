ARG NODE_VERSION=16

FROM node:${NODE_VERSION}-alpine3.15 as build

RUN mkdir -p /usr/src/softhsm
WORKDIR /usr/src/softhsm

## Install Required Dependencies
RUN apk add --update --no-cache git sqlite sqlite-dev rsyslog g++ make autoconf automake libtool openssl-dev

COPY SoftHSM-hashingPatch.tar.gz ./
RUN tar -xf SoftHSM-hashingPatch.tar.gz

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

