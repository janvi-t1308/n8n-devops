resource "aws_key_pair" "developer" {
  key_name   = "janvi-workstation"
  public_key = file(pathexpand(var.public_key_path))
}