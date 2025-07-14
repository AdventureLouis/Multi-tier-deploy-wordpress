
#Output Public IP for SSH Access

output "ec2_public_ip"{
  value = aws_instance.dev-ec2.public_ip
  description = "Public IP address of the EC2 instance"

  }

output "ec2_endpoint"{
  description = "The DNS of of the ec2 instance"
  value = aws_instance.dev-ec2.public_dns

  }



# Step 4: Output Private Key Retrieval Instructions

output "private_key_retrieval_command" {
  value = "aws secretsmanager get-secret-value --secret-id keepsecret --query 'SecretString' --output text > private_key.pem&& chmod 400 private_key.pem"
  description = "Command to retrieve the private key from Secrets Manager and save it locally"
}

output "login_access_to_ec2" {
  value = ""
  description = "SSH command to access the EC2 instance"
}

output "login_access_to_wordpress" {
  value = "http://${aws_instance.dev-ec2.public_ip}/index.php"
}


output "rds_endpoint" {
    description = "The mariadb instance endpoint"
    value = aws_db_instance.dev-mariadb.endpoint
    sensitive = true
}

output "login_access_to_rds" {
  value = "mysql -h ${aws_db_instance.dev-mariadb.address} -P ${aws_db_instance.dev-mariadb.port} -u ${var.kez_user} -p${var.db_pass}"
  #sensitive = true  # Add this since it contains password information
}
# Output ALB DNS name
output "alb_dns_name" {
  value = aws_lb.wordpress_alb.dns_name
}

# Output the name servers for the public hosted zone
output "nameservers" {
  value = aws_route53_zone.main.name_servers
  description = "Name servers for the hosted zone"
}

# Output the zone ID
output "zone_id" {
  value = aws_route53_zone.main.zone_id
  description = "Hosted zone ID"
}

output "website_domain" {
  value       = "http://lab-loui.org"
  description = "Main website domain (HTTP)"
}

output "secure_website_url" {
  value       = "https://lab-loui.org"
  description = "Secure website URL"
}





