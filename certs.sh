#!/bin/bash

valid_answer=false

while [[ $valid_answer == false ]]; do
    read -rp "Do you want to create CA key and certificate? (Y/N): " answer

    if [[ $answer == "Y" || $answer == "y" ]]; then
        valid_answer=true
        result="Yes"
    elif [[ $answer == "N" || $answer == "n" ]]; then
        valid_answer=true
        result="No"
    else
        echo "Invalid answer. Please enter 'Y' or 'N'."
    fi
done

case $result in
"Yes")
    echo "CA key and certificate is being created:"
    # Create a CA Key (your own little on-premise Certificate Authority)
    openssl genpkey -algorithm RSA -aes128 -out private-ca.key -outform PEM -pkeyopt rsa_keygen_bits:2048
    # Create a CA certificate
    openssl req -x509 -new -nodes -sha256 -days 3650 -key private-ca.key -out self-signed-ca-cert.crt
    ;;
"No")
    echo "No CA key or certificate is created."
    ;;
esac

echo "Creating cert:"
read -rp "Any name is ok for the certificate: " certname

mkdir "$certname"
# Create a Key for a service
openssl genpkey -algorithm RSA -out "$certname"/"$certname".key -outform PEM -pkeyopt rsa_keygen_bits:2048
# Create the certificate request file
openssl req -new -key "$certname"/"$certname".key -out "$certname"/"$certname".csr

# Create a text file with some settings
cat <<EOF >"$certname"/"$certname".ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
EOF
echo "DNS.1 = $certname.arpa" >>"$certname"/"$certname".ext
echo "DNS.2 = www.$certname.arpa" >>"$certname"/"$certname".ext

# Create a certificate, signed from the root CA
openssl x509 -req -in "$certname"/"$certname".csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out "$certname"/"$certname".crt -days 365 -sha256 -extfile "$certname"/"$certname".ext

echo "Script ended successfully."
exit 0

# More info on https://github.com/dani-garcia/vaultwarden/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome