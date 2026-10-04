resource "aws_key_pair" "developer" {
  key_name   = "janvi-workstation"
  public_key = var.SSH_public_key
}