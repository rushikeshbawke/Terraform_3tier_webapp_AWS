resource "aws_key_pair" "shared-key" {
  key_name   = "demo-keys"
  public_key = file("C:/Users/RUSHIKESH BAWKE/ssh-key-aws/keys/demo-keys.pub")
}
