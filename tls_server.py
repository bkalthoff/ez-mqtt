#!/bin/env python3
import socket
import ssl
import logging
import pprint

# Configure logging
logging.basicConfig(level=logging.INFO)

# Server configuration
server_address = ('0.0.0.0', 8883)
server_cert = 'mosquitto/config/certs/server.crt'
server_key = 'mosquitto/config/certs/server.key'
ca_cert = 'mosquitto/config/certs/ca.crt'

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the port
sock.bind(server_address)
sock.listen(5)

logging.info(f'Server listening on {server_address}')

def log_certificate_info(cert):
    logging.info("Client certificate info:")
    for key, value in cert.items():
        logging.info(f"{key}: {value}")

def handle_client_connection(connstream):
    try:
        data = connstream.recv(1024)
        logging.info(f'Received data: {data}')
        connstream.sendall(b'HTTP/1.1 200 OK\r\n\r\nHello, TLS client!')
    finally:
        connstream.shutdown(socket.SHUT_RDWR)
        connstream.close()

while True:
    # Wait for a connection
    connection, client_address = sock.accept()
    logging.info(f'Connection from {client_address}')
    
    try:
        # Wrap the connection with TLS
        context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        context.load_cert_chain(certfile=server_cert, keyfile=server_key)
        context.load_verify_locations(cafile=ca_cert)
        context.verify_mode = ssl.CERT_REQUIRED
        
        connstream = context.wrap_socket(connection, server_side=True)
        
        # Get the client certificate
        client_cert = connstream.getpeercert()
        if client_cert:
            log_certificate_info(client_cert)
        
        handle_client_connection(connstream)
        
    except ssl.SSLError as e:
        logging.error(f'TLS error: {e}')
        if e.verify_code is not None:
            logging.error(f'Error verifying certificate: {e.verify_code} - {ssl.cert_verify_error(e.verify_code)}')
        if hasattr(e, 'peer_certificate'):
            logging.error(f'Client certificate: {pprint.pformat(e.peer_certificate)}')
        connection.close()
    except Exception as e:
        logging.error(f'Unexpected error: {e}')
        connection.close()
