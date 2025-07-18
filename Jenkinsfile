pipeline {
  agent none
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

  stages {
    stage('Build and Push Docker Image') {
      agent {
        kubernetes {
            yaml """
              apiVersion: v1
              kind: Pod
              metadata:
                name: kaniko
              spec:
                containers:
                - name: jnlp
                  workingDir: /tmp/jenkins
                - name: kaniko
                  workingDir: /tmp/jenkins
                  image: gcr.io/kaniko-project/executor:debug
                  imagePullPolicy: Always
                  command:
                  - /busybox/cat
                  tty: true
            """
          }
        }
        environment {
          PATH = "/busybox:/kaniko:$PATH"
        }
        steps {
          container(name: 'kaniko', shell: '/busybox/sh') {
              sh '''#!/busybox/sh
              /kaniko/executor --dockerfile=Dockerfile --context=/tmp/jenkins/workspace/app-cloud --destination=$ECR_REPO_URI:$IMAGE_TAG --verbosity debug
              '''
          }
        }
      }
    stage('Deploy') {
      agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: helm
                image: jakexks/kubectl-helm-aws:latest
                command: ["cat"]
                tty: true
            """
        }
      }
      steps {
        container('helm') {
          withCredentials([file(credentialsId: 'k3s-config', variable: 'KUBECONFIG')]) {
            sh '''
            aws ecr get-login-password --region AWS_REGION | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com
            helm upgrade --install word-cloud-generator ./helm/ \\
                        --set image.repository=${ECR_REPO_URI} \\
                        --set image.tag=${IMAGE_TAG} \\
                        -f ./helm/values.yaml \\
                        --namespace word-cloud
            '''
          }
        }
      }
    }
  }
}
