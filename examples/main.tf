provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "ami-d7b9a2b1"
  instance_type = "${var.instance_type}"
}
