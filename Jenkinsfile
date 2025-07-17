pipeline {
  agent {
    kubernetes {
        yaml """
            apiVersion: v1
            kind: Pod
            spec:
            containers:
            - name: jnlp
              workingDir: /tmp/jenkins
            - name: buildx
              workingDir: /tmp/jenkins
              image: papanin123/buildx:latest
              imagePullPolicy: Always
              command:
              - /busybox/cat
              tty: true
            - name: devops
              workingDir: /tmp/jenkins
              image: amazon/aws-cli:2.15.3
              command:
              - sleep
              args:
              - infinity
            """
    }
  }
  environment {
      AWS_REGION = 'us-east-1' // Replace with your AWS region
      AWS_ACCOUNT_ID = '837781915459' // Replace with your AWS Account ID
      AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud' // Replace with your ECR repository name
      IMAGE_TAG = 'latest' // Replace with your desired image tag
      AWS_ECR_REPOSITORY_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
  }

  stages {
    stage('Login to ECR') {
      steps {
        container('devops') {
          sh '''
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR_REPOSITORY_URI
          '''
        }
      }
    }
    stage('Build and Push Docker Image') {
        steps {
          container(name: 'buildx', shell: '/busybox/sh') {
              sh '''
                docker buildx create --use || true
                docker buildx build --platform linux/amd64 -t $AWS_ECR_REPOSITORY_URI:latest --push .
              '''
          }
        }
    }
    stage('Deploy App to K3s cluster') {
        steps {
          container(name: 'devops', shell: '/bin/bash') {
              sh '''#!/bin/bash
              helm version
              aws --version
              kubectl version --client
              docker --version
              '''
            }
        }
    }
  }
}
