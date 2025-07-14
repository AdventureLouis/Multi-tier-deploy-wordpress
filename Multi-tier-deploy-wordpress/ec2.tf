#Template creation
locals {
  wp_config = templatefile("files/config.wp-config.php", { 
    db_port   = tostring(aws_db_instance.dev-mariadb.port)
    db_host   = aws_db_instance.dev-mariadb.endpoint
    kez_user  = var.kez_user
    db_pass   = var.db_pass
    base_name = var.base_name
  })
}



# Optimized EC2 Instance
resource "aws_instance" "dev-ec2" {
    depends_on                  = [aws_internet_gateway.Igw]
    ami                        = var.my-ami
    associate_public_ip_address = true
    instance_type              = "t2.micro"
    key_name                   = aws_key_pair.newkeypair.key_name
    vpc_security_group_ids     = [aws_security_group.ec2-sg.id]
    subnet_id                  = aws_subnet.public-subnet1-eu-west-1a.id
    iam_instance_profile       = aws_iam_instance_profile.ec2_profile.name

    # Use user_data instead of provisioners
    user_data = base64encode(<<-EOF
#!/bin/bash
set -e
# Log setup process
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution..."

# Update system and install required packages
sudo yum update -y
sudo yum remove -y mariadb-libs || true
sudo yum clean all
sudo yum clean metadata

# Install MariaDB (MySQL) client
sudo yum install -y mariadb105 mariadb105-server mysql

# Install other required packages(php 7.4)
# Enable Amazon Linux Extras for PHP 7.4
sudo amazon-linux-extras enable php7.4

# Clean YUM cache
sudo yum clean metadata

# Remove old PHP if installed
sudo yum remove -y php php-*

# Install PHP 7.4 and required modules
sudo yum install -y php php-cli php-mysqlnd php-json php-gd php-mbstring php-xml php-fpm php-opcache

# Restart Apache after PHP installation
sudo systemctl restart httpd


 # Set proper permissions
# sudo chown apache:apache /var/www/html/wp-config.php
# sudo chmod 644 /var/www/html/wp-config.php


# cat > /home/ec2-user/test-db.sh <<TESTDB

# mysql -h ${aws_db_instance.dev-mariadb.address} \
#       -P ${aws_db_instance.dev-mariadb.port} \
#       -u ${var.kez_user} \
#       -p${var.db_pass} \
#       -e "SELECT VERSION();"
# TESTDB

# chmod +x /home/ec2-user/test-db.sh
# chown ec2-user:ec2-user /home/ec2-user/test-db.sh


 # Additional WordPress setup if needed
 # Download and configure WordPress if not already done

# Install wordpress and extract

# Change to the html directory
cd /var/www/html/

 # Clean up
sudo rm -rf wordpress latest.tar.gz


# Download WordPress
sudo wget https://wordpress.org/latest.tar.gz

# Extract WordPress
sudo tar -xzf latest.tar.gz

# Verify extraction
if [ ! -d "/var/www/html/wordpress" ]; then
    echo "WordPress extraction failed"
    exit 1
fi
# Copy WordPress files to the root directory
sudo cp -r wordpress/* /var/www/html/


# Config.php installation,Navigate to web root
cd /var/www/html/

# Copy the sample config
sudo cp wp-config-sample.php wp-config.php

# Update the configuration with actual database details
sudo sed -i "s/database_name_here/${var.base_name}/" wp-config.php
sudo sed -i "s/username_here/${var.kez_user}/" wp-config.php
sudo sed -i "s/password_here/${var.db_pass}/" wp-config.php
sudo sed -i "s/localhost/${aws_db_instance.dev-mariadb.endpoint}/" wp-config.php

# Set proper permissions
sudo chown apache:apache wp-config.php
sudo chmod 640 wp-config.php

# Verify wp-config.php creation
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Failed to create wp-config.php"
    exit 1
fi
# Set proper ownership and permissions
sudo chown -R apache:apache /var/www/html/
sudo chmod 2775 /var/www/html/
find /var/www/html/ -type d -exec sudo chmod 2775 {} \;
find /var/www/html/ -type f -exec sudo chmod 0644 {} \;
sudo chmod 640 /var/www/html/wp-config.php







# Start and enable services
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "User data script completed"

# Create MySQL setup script
cat > /tmp/setup-db.sql <<SQLSETUP
CREATE USER IF NOT EXISTS '${var.kez_user}'@'%' IDENTIFIED BY '${var.db_pass}';
GRANT ALL PRIVILEGES ON ${var.base_name}.* TO '${var.kez_user}'@'%';
FLUSH PRIVILEGES;
SQLSETUP
# Run the setup script
mysql -h ${aws_db_instance.dev-mariadb.address} \
      -P ${aws_db_instance.dev-mariadb.port} \
      -u ${var.kez_user} \
      -p ${var.db_pass} < /tmp/setup-db.sql

# Remove the setup script
rm /tmp/setup-db.sql

# Test the connection
mysql -h ${aws_db_instance.dev-mariadb.address} \
      -P ${tostring(aws_db_instance.dev-mariadb.port)} \
      -u ${var.kez_user} \
      -p ${var.db_pass} \
      -e "SELECT VERSION();"
EOF
    )

    

    tags = {
      Name = "private ec2"
    }

    root_block_device {
      volume_size = 20  # Adjust size as needed
      volume_type = "gp3"
      encrypted   = true
    }

    # Add metadata options for IMDSv2
    metadata_options {
      http_endpoint               = "enabled"
      http_tokens                = "required"
      http_put_response_hop_limit = 1
    }

    lifecycle {
      ignore_changes = [user_data]
    }
}

# Optional: Wait for instance to be ready
resource "time_sleep" "wait_for_instance" {
  depends_on = [aws_instance.dev-ec2]
  create_duration = "90s"
}

# Optional: Output the public IP
output "instance_public_ip" {
  value = aws_instance.dev-ec2.public_ip
}








