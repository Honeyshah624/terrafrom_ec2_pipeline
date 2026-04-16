pipeline {
    agent any

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'ap-south-1', description: 'AWS Region')
        string(name: 'AMI_ID', defaultValue: 'ami-0a1b0c508e1fa9fce', description: 'AMI ID')
        string(name: 'VPC_ID', defaultValue: 'vpc-0ff091a8e9aca2a61', description: 'VPC ID')
        string(name: 'SUBNET_ID', defaultValue: 'subnet-00348d7a114bbb1e0', description: 'Subnet ID')
        string(name: 'INSTANCE_TYPE', defaultValue: 't2.micro', description: 'EC2 Instance Type')
        string(name: 'KEY_NAME', defaultValue: 'my-secure-key', description: 'AWS Key Pair Name')
    }

    environment {
        TF_IN_AUTOMATION = "true"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Create tfvars') {
            steps {
                writeFile file: 'terraform.tfvars', text: """
key_name         = "${params.KEY_NAME}"
ami_id           = "${params.AMI_ID}"
aws_region       = "${params.AWS_REGION}"
instance_type    = "${params.INSTANCE_TYPE}"
vpc_id           = "${params.VPC_ID}"
subnet_id        = "${params.SUBNET_ID}"
ssh_user         = "ubuntu"
ssh_port         = 22
enable_remote_exec = true

remote_exec_inline = [
  "sudo apt-get update -y",
  "sudo apt-get install -y nginx",
  "sudo systemctl enable nginx",
  "sudo systemctl start nginx",
  "echo '<h1>Nginx installed dynamically through remote-exec</h1>' | sudo tee /var/www/html/index.html"
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

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'TF_VAR_PUBLIC_KEY', variable: 'TF_VAR_public_key'),
                    sshUserPrivateKey(credentialsId: 'TF_VAR_PRIVATE_KEY', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_USER')
                ]) {
                    script {
                        env.TF_VAR_private_key = readFile(SSH_KEY_FILE).trim()
                    }
                    sh 'terraform plan -var-file=terraform.tfvars'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve apply?'
                withCredentials([
                    string(credentialsId: 'TF_VAR_PUBLIC_KEY', variable: 'TF_VAR_public_key'),
                    sshUserPrivateKey(credentialsId: 'TF_VAR_PRIVATE_KEY', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_USER')
                ]) {
                    script {
                        env.TF_VAR_private_key = readFile(SSH_KEY_FILE).trim()
                    }
                    sh 'terraform apply -auto-approve -var-file=terraform.tfvars'
                }
            }
        }
    }

    post {
        always {
            sh 'rm -f terraform.tfvars'
        }
    }
}