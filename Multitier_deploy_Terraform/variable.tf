variable "vpc-cidr"{
    type = string
    default = "10.0.0.0./16"
}


variable "my-ami" {
    type = string
    default = "ami-068d1303a1458fb15"
  
}