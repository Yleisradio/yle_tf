provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  tags {
    Name = "example-#{var.env}"
  }
}
