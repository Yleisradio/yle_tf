variable "region" {
  description = "The AWS region for the resources"
  default     = "eu-west-1"
}

variable "env" {
  # passed by `tf`
  description = "The environment"
}

variable "aws_access_key" {
  description = "Your AWS access key id"
}

variable "aws_secret_key" {
  description = "Your AWS secret key"
}

variable "instance_type" {
  description = "Instance type to use"
  default     = "t2.micro"
}
