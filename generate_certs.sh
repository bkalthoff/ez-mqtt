#!/bin/bash

# Check if the number of clients is provided as an argument
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <number_of_clients>"
	exit 1
fi

# Set the number of clients
NUM_CLIENTS=$1

# Define base directories
SCRIPT_DIR=$(dirname "$0")
BASE_DIR="$SCRIPT_DIR/client_certs"
CA_CERT="$SCRIPT_DIR/mosquitto/config/certs/ca.crt"
CA_KEY="$SCRIPT_DIR/mosquitto/config/certs/ca.key"
CA_CERT_NAME="AmazonRootCA1.pem"

generate_unique_uuid() {
	cat /proc/sys/kernel/random/uuid
}


for i in $(seq 1 $NUM_CLIENTS); do
	UNIQUE_UUID=$(generate_unique_uuid)
	CLIENT_DIR="$BASE_DIR/$UNIQUE_UUID"
	CLIENT_KEY="$CLIENT_DIR/$UNIQUE_UUID-private.pem.key"
	CLIENT_CSR="$CLIENT_DIR/$UNIQUE_UUID.csr"
	CLIENT_CERT="$CLIENT_DIR/$UNIQUE_UUID-certificate.pem.crt"

	sudo mkdir -p $CLIENT_DIR

	# Generate client private key
	sudo openssl genpkey -algorithm RSA -out $CLIENT_KEY

	# Generate CSR
	sudo openssl req -new -key $CLIENT_KEY -out $CLIENT_CSR -subj "/CN=client_$UNIQUE_UUID"

	# Sign the certificate with CA
	sudo openssl x509 -req -in $CLIENT_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $CLIENT_CERT -days 365

	# Copy the server certificate to the client directory
	sudo cp $CA_CERT $CLIENT_DIR/$CA_CERT_NAME

	# Delete the CSR
	sudo rm $CLIENT_CSR

	# Change permissions to make files readable by the user
	sudo chmod 644 $CLIENT_KEY $CLIENT_CERT $CA_CERT
done

echo "Client certificates and keys generated successfully."
