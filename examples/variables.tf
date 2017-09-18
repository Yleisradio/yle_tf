variable "region" {
  description = "The AWS region for the resources"
  default     = "eu-west-1"
}

variable "env" {
  # passed by `tf`
  description = "The environment"
}

variable "ami" {
  description = "The AMI to use"
  default     = "ami-d7b9a2b1"
}

variable "instance_type" {
  description = "Instance type to use"
  default     = "t2.micro"
}
