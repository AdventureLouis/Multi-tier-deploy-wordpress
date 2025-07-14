# #!/bin/bash
# set -e

# # Log setup process
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# echo "Starting user data script execution..."

# # Update system and install required packages
# sudo yum update -y
# sudo yum remove -y mariadb-libs || true
# sudo yum clean all
# sudo yum clean metadata

# # Install MariaDB (MySQL) client
# sudo yum install -y mariadb105 mariadb105-server mysql

# # Install other required packages
# sudo yum install -y httpd php php-mysqlnd

# # Create wp-config.php
# cat > /var/www/html/wp-config.php <<'WPCONFIG'
# ${wp_config}
# WPCONFIG

# # Set proper permissions
# sudo chown apache:apache /var/www/html/wp-config.php
# sudo chmod 644 /var/www/html/wp-config.php

# # Start and enable services
# sudo systemctl start httpd
# sudo systemctl enable httpd
# sudo systemctl start mariadb
# sudo systemctl enable mariadb

# cat > /home/ec2-user/test-db.sh <<TESTDB
# mysql -h ${db_host} \
#       -P ${db_port} \
#       -u ${db_user} \
#       -p${db_pass} \
#       -e "SELECT VERSION();"
# TESTDB

# chmod +x /home/ec2-user/test-db.sh
# chown ec2-user:ec2-user /home/ec2-user/test-db.sh

# echo "User data script completed"

# # Create MySQL setup script
# cat > /tmp/setup-db.sql <<SQLSETUP
# CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
# GRANT ALL PRIVILEGES ON ${base_name}.* TO '${db_user}'@'%';
# FLUSH PRIVILEGES;
# SQLSETUP

# # Run the setup script
# mysql -h ${db_host} \
#       -P ${db_port} \
#       -u ${db_user} \
#       -p${db_pass} < /tmp/setup-db.sql

# # Remove the setup script
# rm /tmp/setup-db.sql

# # Test the connection
# mysql -h ${db_host} \
#       -P ${db_port} \
#       -u ${db_user} \
#       -p${db_pass} \
#       -e "SELECT VERSION();"



# # #!/bin/bash
# # ## Install Apache http webserver,Mariadb10.5 and PHP8.2
# # sudo yum update -y
# # cat /etc/system-release
# # sudo amazon-linux-extras install php8.2
# # sudo yum install -y httpd
# # yum info package_name
# # sudo systemctl start httpd
# # sudo systemctl enable httpd
# # sudo systemctl is-enabled httpd

# # ## Set file permisions
# # sudo usermod -a -G apache ec2-user
# # exit
# # sudo chown -R ec2-user:apache /var/www
# # groups
# # sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
# # find /var/www -type f -exec sudo chmod 0664 {} \;
# # echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
# # sudo yum list installed httpd mariadb-server php-mysqlnd
# # rm /var/www/html/phpinfo.php

# # ## Install wordpress and extract
# # wget https://wordpress.org/latest.tar.gz
# # tar -xzf latest.tar.gz
# # sudo cp -r wordpress/* /var/www/html/
# # cp wordpress/wp-config-sample.php wordpress/wp-config.php
# # sudo nano /etc/httpd/conf/httpd.conf



# # #Make wordpress run under apache server
# # sudo chown -R apache /var/www/html/
# # sudo chgrp -R apache /var/www/html/
# # sudo chmod 2775 /var/www/html/
# # find /var/www -type d -exec sudo chmod 2775 {} \;
# # find /var/www -type f -exec sudo chmod 0644 {} \;
# # rm -rf wordpress latest.tar.gz
# # sudo systemctl restart httpd


# # #Install mariadb 10.5,create a user and start the mariadb
# # #!/bin/bash
# # set -e  # Exit on any error

# # # Enable logging
# # exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# # echo "Starting MariaDB installation..."

# # # Remove existing packages first
# # sudo yum remove -y mariadb-libs

# # # Clean up
# # sudo yum clean all

# # # Install the MariaDB repository
# # sudo tee /etc/yum.repos.d/MariaDB.repo<<EOF
# # [mariadb]
# # name = MariaDB
# # baseurl = http://yum.mariadb.org/10.5/centos7-amd64
# # gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
# # gpgcheck=1
# # EOF

# # # Update system
# # sudo yum update -y

# # # Install MariaDB client and libraries
# # sudo yum install -y MariaDB-client MariaDB-shared

# # # Verify installation
# # echo "Verifying installation..."

# # # Check for mysql client
# # if ! command -v mysql &> /dev/null; then
# #     echo "MySQL/MariaDB client not found"
# #     exit 1
# # fi

# # # Check for libraries
# # echo "Checking installed packages:"
# # rpm -qa | grep -i maria

# # # Check mysql version
# # echo "MySQL/MariaDB version:"
# # mysql --version

# # # Check library links
# # echo "Checking library links:"
# # ls -l /usr/lib64/mysql* || echo "No MySQL libraries found in /usr/lib64"
# # ls -l /usr/lib64/libmariadb* || echo "No MariaDB libraries found in /usr/lib64"

# # echo "MariaDB client installation completed successfully"

# # # Update the system first
# # # !/bin/bash

# # # # Enable logging
# # # exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# # # echo "Starting MariaDB installation..."

# # # # Update system
# # # sudo yum update -y
# # # if [ $? -ne 0 ]; then
# # #     echo "System update failed"
# # #     exit 1
# # # fi

# # # # Enable MariaDB repository
# # # echo "Enabling MariaDB repository..."
# # # sudo amazon-linux-extras enable mariadb10.5
# # # if [ $? -ne 0 ]; then
# # #     echo "Failed to enable MariaDB repository"
# # #     exit 1
# # # fi

# # # # Clean metadata
# # # echo "Cleaning yum metadata..."
# # # sudo yum clean metadata
# # # if [ $? -ne 0 ]; then
# # #     echo "Failed to clean metadata"
# # #     exit 1
# # # fi

# # # # Install MariaDB
# # # echo "Installing MariaDB..."
# # # sudo yum install -y mariadb
# # # if [ $? -ne 0 ]; then
# # #     echo "MariaDB installation failed"
# # #     exit 1
# # # fi

# # # # Verify installation
# # # if ! command -v mysql &> /dev/null; then
# # #     echo "MySQL/MariaDB client not found after installation"
    
# # #     # Additional debugging information
# # #     echo "Checking installed packages:"
# # #     rpm -qa | grep -i maria
# # #     echo "Checking mysql binary location:"
# # #     which mysql || echo "mysql not in PATH"
# # #     echo "Checking default paths:"
# # #     ls -l /usr/bin/mysql* || echo "No mysql binaries in /usr/bin"
    
# # #     exit 1
# # # fi

# # # echo "MariaDB installation completed successfully"
# # # mysql --version


# # # #!/bin/bash
# # # set -e  # Exit on any error

# # # # Enable logging
# # # exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# # # echo "Starting MariaDB installation..."

# # # # Remove existing packages first
# # # sudo yum remove -y mariadb-libs

# # # # Clean up
# # # sudo yum clean all

# # # # Install the MariaDB repository
# # # sudo tee /etc/yum.repos.d/MariaDB.repo<<EOF
# # # [mariadb]
# # # name = MariaDB
# # # baseurl = http://yum.mariadb.org/10.5/centos7-amd64
# # # gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
# # # gpgcheck=1
# # # EOF

# # # # Update system and install MariaDB client
# # # sudo yum update -y
# # # sudo yum install -y MariaDB-client

# # # # Verify installation
# # # if ! command -v mysql &> /dev/null; then
# # #     echo "MariaDB client installation failed"
# # #     # Debug information
# # #     echo "Installed packages:"
# # #     rpm -qa | grep -i maria
# # #     echo "Binary locations:"
# # #     ls -l /usr/bin/mysql* || echo "No mysql binaries found"
# # #     exit 1
# # # fi

# # # echo "MariaDB client installation completed successfully"
# # # mysql --version
