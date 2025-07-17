pipeline {
  agent {
    kubernetes {
      yaml """
        apiVersion: v1
        kind: Pod
        spec:
        containers:
            - name: jnlp
            image: jenkins/inbound-agent
            workingDir: /home/jenkins/agent
            - name: buildx
            image: papanin123/buildx:latest
            workingDir: /workspace
            command:
            - /busybox/cat
            tty: true
            - name: deploy
            image: amazon/aws-cli:2.15.3
            workingDir: /workspace
            command:
            - sleep
            args:
            - infinity
            env:
            - name: AWS_REGION
              value: us-east-1
        """
    }
  }

  environment {
      AWS_REGION = 'us-east-1' // Replace with your AWS region
      AWS_ACCOUNT_ID = '837781915459' // Replace with your AWS Account ID
      AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud' // Replace with your ECR repository name
      IMAGE_TAG = 'latest' // Replace with your desired image tag
      ECR_REPO_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
  }

  stages {
    stage('Checkout') {
      steps {
        container('jnlp') {
          checkout scm
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        container('buildx') {
          script {
            sh '''
              export DOCKER_CLI_EXPERIMENTAL=enabled
              aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI
              docker buildx build --platform linux/amd64 \
                -t $ECR_REPO:$IMAGE_TAG \
                --push .
            '''
          }
        }
      }
    }

    stage('Create K8s Secret for ECR') {
      steps {
        container('deploy') {
          script {
            sh '''
              aws ecr get-login-password --region $AWS_REGION | \
              kubectl create secret docker-registry regcred \
                --docker-server=$ECR_REPO_URI \
                --docker-username=AWS \
                --docker-password-stdin \
                --dry-run=client -o yaml | kubectl apply -f -
            '''
          }
        }
      }
    }

    stage('Deploy with Helm') {
      steps {
        container('deploy') {
          sh '''
            helm upgrade --install my-app ./chart \
              --set image.repository=$ECR_REPO_URI \
              --set image.tag=$IMAGE_TAG \
              --set image.pullSecrets[0].name=regcred
          '''
        }
      }
    }
  }
}
