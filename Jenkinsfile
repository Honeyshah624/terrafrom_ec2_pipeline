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
        string(name: 'ssh_port', description: 'SSH Port')

        booleanParam(
            name: 'ENABLE_REMOTE_EXEC',
            defaultValue: true,
            description: 'Enable remote-exec provisioner'
        )

        text(
            name: 'REMOTE_EXEC_COMMANDS',
            description: 'Terraform list value of remote exec inline commands'
        )

        text(
            name: 'INGRESS_RULES',
            description: 'Terraform list value of ingress rules'
        )

        text(
            name: 'EGRESS_RULE',
            description: 'Terraform object value of egress rule'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
                        def privateKey = readFile(SSH_KEY_FILE).trim()

                        withEnv([
                            "TF_VAR_private_key=${privateKey}",
                            "TF_VAR_key_name=${params.KEY_NAME}",
                            "TF_VAR_ami_id=${params.AMI_ID}",
                            "TF_VAR_aws_region=${params.AWS_REGION}",
                            "TF_VAR_instance_type=${params.INSTANCE_TYPE}",
                            "TF_VAR_vpc_id=${params.VPC_ID}",
                            "TF_VAR_subnet_id=${params.SUBNET_ID}",
                            "TF_VAR_vpc_cidr=${params.VPC_CIDR}",
                            "TF_VAR_ssh_user=${params.ssh_user}",
                            "TF_VAR_ssh_port=${params.ssh_port}",
                            "TF_VAR_enable_remote_exec=${params.ENABLE_REMOTE_EXEC.toString()}",
                            "TF_VAR_remote_exec_inline=${params.REMOTE_EXEC_COMMANDS.trim()}",
                            "TF_VAR_ingress_rules=${params.INGRESS_RULES.trim()}",
                            "TF_VAR_egress_rule=${params.EGRESS_RULE.trim()}",
                            """TF_VAR_common_tags={
                                                  "Resource Owner": "Honey Shah",
                                                  "Create-Date": "17 April 2026",
                                                  "Sub Business Unit": "PES-IA",
                                                  "Project Name": "Testing and Learning",
                                                  "Delivery Manager": "Shahid Raza"
                                                }"""
                        ]) {
                            sh 'terraform plan -out=tfplan'
                        }
                    }

                    stash name: 'terraform-plan', includes: 'tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve apply?'
                unstash 'terraform-plan'

                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
}