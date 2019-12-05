FROM node:10.17.0-alpine3.10 as build

RUN mkdir -p /usr/src/softhsm
WORKDIR /usr/src/softhsm

## Install Required Dependencies
RUN apk add --repository https://alpine.global.ssl.fastly.net/alpine/v3.10/main --update --no-cache git sqlite sqlite-dev rsyslog g++ make autoconf automake libtool openssl-dev

# Fetch SoftHSM Modified Code
ARG SOFTHSM_GIT_REPO=https://github.com/Ticto/SoftHSMv2.git

# SoftHSM v2.2.0
ARG SOFTHSM_COMMIT_HASH=9d6ff8ee92f05836f4681b171b02472a5b82de40

## Fetch Correct SoftHSM Code Commit
RUN git init && \
  git remote add origin $SOFTHSM_GIT_REPO && \
  git pull origin master && \
  git checkout $SOFTHSM_COMMIT_HASH

## Compile & Install
RUN sh ./autogen.sh && ./configure --disable-gost && make && make install

## RUNTIME
FROM node:10.17.0-alpine3.10

COPY --from=build /usr/local/lib/softhsm /usr/local/lib/softhsm
COPY --from=build /usr/local/bin/softhsm2* /usr/local/bin/
COPY --from=build /var/lib/softhsm/tokens /var/lib/softhsm/tokens

RUN apk add --repository https://alpine.global.ssl.fastly.net/alpine/v3.10/main --update --no-cache openssl-dev openssl

ENV SOFTHSM2_CONF /etc/softhsm2.conf
ADD softhsm2.conf /etc/softhsm2.conf

# Initiate SoftHSM Default if no other one is mounted, can be used for testing
COPY init_softhsm.sh /etc/
ENTRYPOINT ["/etc/init_softhsm.sh"]
