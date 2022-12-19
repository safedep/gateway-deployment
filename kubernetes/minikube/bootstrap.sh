#!/bin/bash

set -ex

BASEDIR="`dirname $0`/manifests"
mkdir -p $BASEDIR/pki

# This is used for container network mTLS only
export ROOT_SUBJ="/C=IN/ST=KA/L=Bangalore/O=SafeDep/OU=DevOps/CN=safedep.io/emailAddress=admin@safedep.io"

openssl req -nodes -new -x509 \
  -keyout $BASEDIR/pki/root.key -out $BASEDIR/pki/root.crt \
  -days 365 \
  -subj $ROOT_SUBJ

export PARTICIPATING_SERVICES="pdp tap dcs pds nats-server"

for svc in $PARTICIPATING_SERVICES; do
  mkdir -p $BASEDIR/pki/$svc

  openssl genrsa -out $BASEDIR/pki/$svc/server.key 2048

  openssl req -new -sha256 -key $BASEDIR/pki/$svc/server.key \
    -subj "/C=IN/ST=KA/O=SafeDep/CN=$svc" \
    -addext "subjectAltName=DNS:$svc" \
    -out $BASEDIR/pki/$svc/server.csr

  openssl x509 -req -in $BASEDIR/pki/$svc/server.csr \
    -CA $BASEDIR/pki/root.crt -CAkey $BASEDIR/pki/root.key -CAcreateserial \
    --extensions v3_req \
    -extfile <(printf "[v3_req]\nsubjectAltName=DNS:$svc") \
    -out $BASEDIR/pki/$svc/server.crt -days 365 -sha256
done

# This is insecure but is needed for docker-compose
# In a production environment, we must use a cert manager instead of
# manually generating certificates

find $BASEDIR/pki -type f -exec chmod 644 {} \;

if [ ! -f "$BASEDIR/.env" ]; then
# Generate secrets
  mysql_root_pass=$(openssl rand -hex 32)
  cat > "$BASEDIR/.env" <<_EOF
MYSQL_ROOT_PASSWORD=$mysql_root_pass
MYSQL_DCS_DATABASE=vdb
MYSQL_DCS_USER=root
MYSQL_DCS_PASSWORD=$mysql_root_pass
_EOF
fi
