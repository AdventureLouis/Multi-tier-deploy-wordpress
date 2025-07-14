

#Generate the key pair
# RSA key of size 4096 bits
resource "tls_private_key" "dev-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Import the public key to AWS as a keypair
resource "aws_key_pair" "newkeypair"{
    key_name = ""
    public_key = tls_private_key.dev-rsa.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.dev-rsa.private_key_pem
  filename        = ""
  file_permission = "0400"  # This sets the file to read-only for the owner
}





