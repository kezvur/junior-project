terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      
    }
    github = {
      source = "integrations/github"
      
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "github" {
  # Configuration options
  token = ""
}

data "github_repository" "myrepo" {
  name = "junior-project"
  
}

data "github_branch" "main" {
  branch = "main"
  repository = data.github_repository.myrepo.name
}


resource "aws_instance" "tf-car-rental" {
  ami = "ami-0f9fc25dd2506cf6d"
  instance_type = "t3a.small"
  key_name = "yusufkey"
  vpc_security_group_ids = [aws_security_group.car-rental-SG.id]
  
  tags = {
    Name = "Project Dev Server"
  }

  user_data = <<-EOF
          #!/bin/bash
          # Update system packages and install necessary tools
          yum update -y
          yum install git -y
          yum install java-11-amazon-corretto -y

          # Install Jenkins
          wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
          rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
          yum install jenkins -y
          systemctl enable jenkins
          systemctl start jenkins

          # Install Docker and Docker Compose
          yum install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          usermod -a -G docker jenkins
          cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
          sed -i 's/^ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/127.0.0.1:2376 -H unix:\/\/\/var\/run\/docker.sock/g' /lib/systemd/system/docker.service
          systemctl daemon-reload

          # Install Docker Compose
          curl -SL https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose

          # Install Python 3 and necessary Python packages
          yum install -y python3-pip python3-devel
          pip3 install ansible
          pip3 install boto3 botocore

          # Install Terraform
          wget https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip
          unzip terraform_1.4.6_linux_amd64.zip -d /usr/local/bin

          # Clone the GitHub repository and set permissions
          cd /home/ec2-user
          git clone https://@github.com/YusufArikdogan/${data.github_repository.myrepo.name}.git
          chown -R ec2-user:ec2-user ${data.github_repository.myrepo.name}
        EOF
}

resource "aws_security_group" "car-rental-SG" {
  name = "car-rental-SG"
  tags = {
    Name = "car-rental-SG"
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
   }
  ingress {
    from_port = 3000
    protocol = "tcp"
    to_port = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 9090
    protocol = "tcp"
    to_port = 9090
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5432
    protocol = "tcp"
    to_port = 5432
    cidr_blocks = ["0.0.0.0/0"]
   }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "Dev-Server" {
  value = "http://${aws_instance.tf-car-rental.public_dns}"

}