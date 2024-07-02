#!/bin/bash

# Define the base directories
SCRIPT_DIR=$(dirname "$0")
BASE_DIR="$SCRIPT_DIR/client_certs"
CA_CERT="$SCRIPT_DIR/mosquitto/config/certs/ca.crt"

# Function to verify a client certificate against the CA certificate
verify_certificate() {
	CLIENT_CERT=$1
	openssl verify -CAfile $CA_CERT $CLIENT_CERT
}

# Function to verify the private key matches the certificate
verify_private_key() {
	CLIENT_KEY=$1
	CLIENT_CERT=$2
	PUBKEY1=$(sudo openssl pkey -in $CLIENT_KEY -pubout -outform pem)
	PUBKEY2=$(openssl x509 -in $CLIENT_CERT -pubkey -noout -outform pem)
	if [ "$PUBKEY1" == "$PUBKEY2" ]; then
		echo "The private key matches the certificate."
	else
		echo "The private key does not match the certificate."
	fi
}

# Loop through each client directory and verify the certificate and private key
for CLIENT_DIR in $BASE_DIR/*; do
	if [ -d "$CLIENT_DIR" ]; then
		CLIENT_CERT=$(find $CLIENT_DIR -name "*-certificate.pem.crt")
		CLIENT_KEY=$(find $CLIENT_DIR -name "*-private.pem.key")
		if [ -f "$CLIENT_CERT" ] && [ -f "$CLIENT_KEY" ]; then
			echo "Verifying $CLIENT_CERT"
			verify_certificate $CLIENT_CERT
			echo "Verifying the private key for $CLIENT_CERT"
			verify_private_key $CLIENT_KEY $CLIENT_CERT
		else
			echo "Certificate or private key not found in $CLIENT_DIR"
		fi
	fi
done
