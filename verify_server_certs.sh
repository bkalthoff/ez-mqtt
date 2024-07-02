#!/bin/bash
# Define the base directories and files
SCRIPT_DIR=$(dirname "$0")
CERTS_DIR="$SCRIPT_DIR/mosquitto/config/certs"
CA_CERT="$CERTS_DIR/ca.crt"
SERVER_CERT="$CERTS_DIR/server.crt"
SERVER_KEY="$CERTS_DIR/server.key"

# Function to verify the server certificate against the CA certificate
verify_certificate() {
	openssl verify -CAfile $CA_CERT $SERVER_CERT
}

# Function to verify the server private key matches the server certificate
verify_private_key() {
	PUBKEY1=$(sudo openssl pkey -in $SERVER_KEY -pubout -outform pem)
	PUBKEY2=$(openssl x509 -in $SERVER_CERT -pubkey -noout -outform pem)
	if [ "$PUBKEY1" == "$PUBKEY2" ]; then
		echo "The server private key matches the server certificate."
	else
		echo "The server private key does not match the server certificate."
	fi
}

# Verify the server certificate
echo "Verifying the server certificate against the CA certificate..."
verify_certificate

# Verify the server private key
echo "Verifying the server private key matches the server certificate..."
verify_private_key
