#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

IP=192.168.1.242
PORT=8883

CAFILE=$SCRIPT_DIR/mosquitto/config/certs/ca.crt
CERTFILE=$SCRIPT_DIR/client_certs/aa1c2ecb-b8b5-4621-bd84-08f9fd32c828/aa1c2ecb-b8b5-4621-bd84-08f9fd32c828-certificate.pem.crt
KEYFILE=$SCRIPT_DIR/client_certs/aa1c2ecb-b8b5-4621-bd84-08f9fd32c828/aa1c2ecb-b8b5-4621-bd84-08f9fd32c828-private.pem.key

openssl s_client -connect $IP:$PORT -CAfile $CAFILE -cert $CERTFILE -key $KEYFILE
