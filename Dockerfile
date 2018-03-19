FROM node:8.10.0-alpine
MAINTAINER Ticto 'development@ticto.com'

RUN mkdir -p /usr/src/softhsm
WORKDIR /usr/src/softhsm

COPY SoftHSM-hashingPatch.tar.gz ./
# Compile & Install
RUN apk add --repository http://nl.alpinelinux.org/alpine/v3.6/main --update --no-cache sqlite sqlite-dev rsyslog
RUN apk add --repository http://nl.alpinelinux.org/alpine/v3.6/main --update --no-cache --virtual .deps g++ make autoconf automake libtool && \
  apk add --repository http://nl.alpinelinux.org/alpine/v3.6/main --no-cache openssl-dev && \
  tar -xf SoftHSM-hashingPatch.tar.gz && \
  sh ./autogen.sh && \
  ./configure && \
  make && make install && \
  rm -rvf /usr/src/softhsm && \
  apk del --purge -r .deps

ENV SOFTHSM2_CONF /etc/softhsm2.conf
ADD softhsm2.conf /etc/softhsm2.conf

# Initiate SoftHSM Default if no other one is mounted, can be used for testing
RUN softhsm2-util --init-token --slot 0 --label "TEST TOKEN" --pin 1234 --so-pin 0000
