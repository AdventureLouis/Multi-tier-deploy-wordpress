#Create RDS security group
resource "aws_security_group" "rds-sg" {
  description = "mariadb security group"
  vpc_id = aws_vpc.dev.id

}

 # Rule to allow EC2 to connect to RDS
resource "aws_security_group_rule" "ec2_to_rds" {
    type                     = "egress"
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    source_security_group_id = aws_security_group.rds-sg.id
    security_group_id       = aws_security_group.ec2-sg.id
}

# Rule to allow RDS to accept connections from EC2
resource "aws_security_group_rule" "rds_from_ec2" {
    type                     = "ingress"
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    source_security_group_id = aws_security_group.ec2-sg.id
    security_group_id       = aws_security_group.rds-sg.id
}

#Create dababase subnet group
resource "aws_db_subnet_group" "mysubnet-grp" {
    name = "kez_subnet_grp"
    subnet_ids = [aws_subnet.private-subnet1-west-1a.id,
    aws_subnet.private-subnet2-west-1b.id,
    aws_subnet.private-subnet3-west-1c.id]
    
  
}

# Create AWS kMS KEY
resource "aws_kms_key" "dev-kms" {
  description  = "KMS key for RDS Encryption"
  deletion_window_in_days = 7
}

#Create  Mariadb Instance
resource "aws_db_instance" "dev-mariadb" {
  allocated_storage    = 20
  engine               = "mariadb"
  engine_version       = "10.11.6"
  instance_class       = "db.t3.micro"
  username             = "loui_mariadb1"
  # manage_master_user_password = true
  # master_user_secret_kms_key_id = aws_kms_key.dev-kms.id
  password = var.db_pass
  db_subnet_group_name = aws_db_subnet_group.mysubnet-grp.id
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_name              = "Db_Wordpress1"
  identifier = "loui-wordpress"
  skip_final_snapshot = true
  storage_encrypted = true
  apply_immediately = true
  #multi_az = true
  tags ={
    Name = "Mariadb instance"
  }
}

