pipeline {
  agent none
  environment {
      AWS_REGION = 'us-east-1' // Replace with your AWS region
      AWS_ACCOUNT_ID = '837781915459' // Replace with your AWS Account ID
      AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud-pub' // Replace with your ECR repository name
      IMAGE_TAG = 'latest' // Replace with your desired image tag
      AWS_ECR_REPOSITORY_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
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
              /kaniko/executor --dockerfile=Dockerfile --context=/tmp/jenkins/workspace/app-cloud --destination=$AWS_ECR_REPOSITORY_URI:$IMAGE_TAG --verbosity debug
              '''
          }
        }
      }
    }
}
