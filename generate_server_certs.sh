#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

CERT_DIR=$SCRIPT_DIR/mosquitto/config/certs

CN="CN=192.168.1.242"
CA_CN="CN=mosquitto-ca"

mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Generate CA key
openssl genpkey -algorithm RSA -out ca.key

# Generate CA certificate
openssl req -new -x509 -key ca.key -out ca.crt -days 3650 -subj "/$CA_CN"

# Generate server key
openssl genpkey -algorithm RSA -out server.key

# Generate server certificate signing request (CSR)
openssl req -new -key server.key -out server.csr -subj "/$CN"

# Sign the server certificate with the CA certificate
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
