pipeline {
  agent none
  environment {
    AWS_REGION = 'us-east-1'
    AWS_ACCOUNT_ID = '837781915459'
    AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud'
    IMAGE_TAG = 'latest'
    ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}"
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
          sh '''
            /kaniko/executor \
              --dockerfile=Dockerfile \
              --context=/tmp/jenkins/workspace/app-cloud \
              --destination=$ECR_URI:$IMAGE_TAG
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
            spec:
              containers:
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
          sh"""
             aws ecr get-login-password --region $AWS_REGION
          """
        }

        container('kubectl') {
          sh """
            kubectl delete secret regcred --ignore-not-found
            kubectl create secret docker-registry regcred \
              --docker-server=${ECR_URI} \
              --docker-username=AWS \
              --docker-password='${AWS_ECR_PASSWORD}' \
              --docker-email=panin.tut@gmail.com
          """
        }
      }
    }
  }
}
