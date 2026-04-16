pipeline {
    agent any

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'ap-south-1', description: 'AWS Region')
        string(name: 'AMI_ID', defaultValue: 'ami-xxxxxxxxxxxxxxxxx', description: 'AMI ID')
        string(name: 'VPC_ID', defaultValue: 'vpc-0ff091a8e9aca2a61', description: 'VPC ID')
        string(name: 'SUBNET_ID', defaultValue: 'subnet-00348d7a114bbb1e0', description: 'Subnet ID')
        text(
            name: 'REMOTE_EXEC_SCRIPT',
            defaultValue: '''sudo apt-get update -y
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
echo '<h1>Nginx installed dynamically through remote-exec</h1>' | sudo tee /var/www/html/index.html''',
            description: 'One command per line'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare tfvars') {
            steps {
                script {
                    def commands = params.REMOTE_EXEC_SCRIPT
                        .split('\n')
                        .collect { line -> line.trim() }
                        .findAll { line -> line }
                        .collect { line -> '  "' + line.replace('\\', '\\\\').replace('"', '\\"') + '"' }
                        .join(",\n")

                    writeFile file: 'jenkins.auto.tfvars', text: """
key_name         = "my-secure-key"
public_key_path  = "/home/jenkins/.ssh/id_rsa.pub"
private_key_path = "/home/jenkins/.ssh/id_rsa"

ssh_user = "ubuntu"
ssh_port = 22

enable_remote_exec = true

aws_region    = "${params.AWS_REGION}"
ami_id        = "${params.AMI_ID}"
instance_type = "t2.micro"
vpc_cidr      = "10.0.0.0/16"
vpc_id        = "${params.VPC_ID}"
subnet_id     = "${params.SUBNET_ID}"

remote_exec_inline = [
${commands}
]

common_tags = {
  "Resource Owner"    = "Honey Shah"
  "Create-Date"       = "16 April 2026"
  "Sub Business Unit" = "PES-IA"
  "Project Name"      = "Testing and Learning"
  "Delivery Manager"  = "Shahid Raza"
}

ingress_rules = [
  {
    description = "ssh from org Range 1"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["182.76.141.104/29"]
  },
  {
    description = "ssh from org Range 2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["115.112.142.32/29"]
  },
  {
    description = "ssh from org Range 3"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.97.73.248/29"]
  },
  {
    description = "http org Range 1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["115.112.142.32/29"]
  },
  {
    description = "http org Range 2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["182.76.141.104/29"]
  },
  {
    description = "http org Range 3"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["14.97.73.248/29"]
  }
]

egress_rule = {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
"""
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform init -input=false'
                sh 'terraform apply -auto-approve -input=false -var-file=jenkins.auto.tfvars'
            }
        }
    }
}