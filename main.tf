provider "aws" {
  region = "us-east-1"
  alias = "usa1"
}

provider "aws" {
  region = "us-east-2"
  alias = "usa2"
}
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair in aws
resource "aws_key_pair" "aws_key" {
  key_name   = "nicko"
  public_key = tls_private_key.ec2_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "nicko.pem"
  content  = tls_private_key.ec2_key.private_key_pem
}



resource "aws_instance" "inst1" {
  provider = aws.usa1
  key_name = aws_key_pair.aws_key.key_name
  ami = "ami-0c8e23f950c7725b9"
  instance_type = "t2.micro"
  
  
}

resource "null_resource" "n1" {
  
  connection {
    type = "ssh"
    port = 22
    user = "ec2-user"
    host = aws_instance.inst1.public_ip
    private_key = file(local_file.ssh_key.filename)
  }

  provisioner "local-exec" {
    command = "touch terraform.txt"
  }
  provisioner "file" {
    source = "terraform.txt"
    destination = "/tmp/terraform.txt"
  }
  provisioner "remote-exec" {
    inline = [  
        "touch nick",
        
     ]
  }
  depends_on = [ aws_instance.inst1,local_file.ssh_key ]
}