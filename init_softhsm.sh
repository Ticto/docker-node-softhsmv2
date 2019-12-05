#!/bin/sh
set -e

#
# Small script that initializes SoftHSM if it happens to be empty (e.g. on fresh deploy)
#

if find /var/lib/softhsm/tokens -mindepth 1 | read; then
   echo "SoftHSM Tokens Exist - Doing Nothing"
else
   echo "SoftHSM Token Does Not Exist - Init SoftHSM"
   softhsm2-util --init-token --slot 0 --label "TEST TOKEN" --pin 1234 --so-pin 0000
fi

exec "$@"