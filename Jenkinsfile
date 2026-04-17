pipeline {
    agent any

    parameters {
        string(name: 'AWS_REGION', description: 'AWS Region')
        string(name: 'AMI_ID', description: 'AMI ID')
        string(name: 'VPC_ID', description: 'VPC ID')
        string(name: 'SUBNET_ID', description: 'Subnet ID')
        string(name: 'INSTANCE_TYPE', description: 'EC2 Instance Type')
        string(name: 'KEY_NAME', description: 'AWS Key Pair Name')
        string(name: 'VPC_CIDR', description: 'VPC CIDR Block')
        string(name: 'ssh_user', description: 'SSH User')
        number(name: 'ssh_port', description: 'SSH Port')

        string(
            name: 'INGRESS_RULES',
            description: 'Terraform format list(object) for ingress rules'
        )

        string(
            name: 'EGRESS_RULE',
            description: 'Terraform format object for egress rule'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Create tfvars') {
            steps {
                script {
                    def commands = readFile('scripts/remote_exec_commands.txt')
                        .split('\n')
                        .collect { it.trim() }
                        .findAll { it && !it.startsWith('#') }

                    def terraformCommands = commands.collect { cmd ->
                        '  "' + cmd.replace('\\', '\\\\').replace('"', '\\"') + '"'
                    }.join(',\n')

                    writeFile file: 'terraform.tfvars', text: """
                           key_name         = "${params.KEY_NAME}"
                           ami_id           = "${params.AMI_ID}"
                           aws_region       = "${params.AWS_REGION}"
                           instance_type    = "${params.INSTANCE_TYPE}"
                           vpc_id           = "${params.VPC_ID}"
                           subnet_id        = "${params.SUBNET_ID}"
                           vpc_cidr         = "${params.VPC_CIDR}"
                           ssh_user         = "${params.ssh_user}"
                           ssh_port         = ${params.ssh_port}
                           enable_remote_exec = true
                           
                           remote_exec_inline = [
                           ${terraformCommands}
                           ]
                           
                           common_tags = {
                             "Resource Owner"    = "Honey Shah"
                             "Create-Date"       = "17 April 2026"
                             "Sub Business Unit" = "PES-IA"
                             "Project Name"      = "Testing and Learning"
                             "Delivery Manager"  = "Shahid Raza"
                           }
                           
                           ingress_rules = ${params.INGRESS_RULES}
                           
                           egress_rule = ${params.EGRESS_RULE}
                           """
                                           }
                                       }
                                   }
                           
        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'TF_VAR_PUBLIC_KEY', variable: 'TF_VAR_public_key'),
                    sshUserPrivateKey(credentialsId: 'TF_VAR_PRIVATE_KEY', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_USER'),
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
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
                    sshUserPrivateKey(credentialsId: 'TF_VAR_PRIVATE_KEY', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_USER'),
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
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