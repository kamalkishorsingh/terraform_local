provider "aws" {
  access_key = "**********************"
  secret_key = "****************************"
  region     = "us-west-2"
}
resource "aws_key_pair" "aws" {
  key_name   = "aws"
  public_key = "ssh-rsa *****************************************************************"
}
