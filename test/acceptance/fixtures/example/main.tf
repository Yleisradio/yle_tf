variable "env" {}

variable "env_specific" {
  default = "default"
}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo '${var.from_hook}, ${var.env} ${var.env_specific}!' > tf_example_test"
  }
}

output "test" {
  value = "${var.from_hook}, ${var.env} ${var.env_specific}!"
}
