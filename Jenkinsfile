pipeline {
  agent none
  environment {
      AWS_REGION = 'us-east-1' // Replace with your AWS region
      AWS_ACCOUNT_ID = '837781915459' // Replace with your AWS Account ID
      AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud' // Replace with your ECR repository name
      IMAGE_TAG = 'latest' // Replace with your desired image tag
      ECR_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
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
                - name: helm
                  image: alpine/helm:3.18.3
                  command:
                    - cat
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
              /kaniko/executor --dockerfile=Dockerfile --context=/tmp/jenkins/workspace/app-cloud --destination=$ECR_URI:$IMAGE_TAG
              '''
          }
        }
      }
    stage('Create ImagePullSecret from ECR') {
       agent {
         kubernetes {
             yaml """
               apiVersion: v1
               kind: Pod
               metadata:
                 name: awscli
               spec:
                - name: awscli
                image: amazon/aws-cli:2.27.54
                command: ['cat']
                tty: true
                - name: kubectl
                image: bitnami/kubectl:latest
                command: ['cat']
                tty: true
             """
         }
       }
       steps {
        container('awscli') {
          script {
            def password = sh(
              script: "aws ecr get-login-password --region $AWS_REGION",
              returnStdout: true
            ).trim()
          }
        }
        steps{
          container('kubectl') {
            script {
              sh """
                kubectl delete secret regcred --ignore-not-found
                kubectl create secret docker-registry regcred \
                  --docker-server=${ECR_URI} \
                  --docker-username=AWS \
                  --docker-password='${password}' \
                  --docker-email=panin.tut@gmail.com
              """
            }
          }
        }
    }
  }
}
