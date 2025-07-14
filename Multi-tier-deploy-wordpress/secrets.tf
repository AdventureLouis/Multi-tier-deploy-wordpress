#Store the private key in AWS secret manager
resource "aws_secretsmanager_secret" "kezsecret"{
  description = "keys to ssh into EC2"
  name = ""
  recovery_window_in_days = 0
}


#Retrieve secrets using secrets manager version
resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = ""
  secret_string = ""
  

  
}





