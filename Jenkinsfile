pipeline {
  agent none
  environment {
    AWS_REGION = 'us-east-1'
    AWS_ACCOUNT_ID = '837781915459'
    AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud'
    IMAGE_TAG = 'latest'
    ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}"
    ECR_SERVER_NAME = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    AWS_ECR_PASSWORD = ''
  }

  stages {
    stage('Build and Push Docker Image') {
      agent {
        kubernetes {
          yaml '''
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
          '''
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

    stage('Create ECR Secret') {
      agent {
        kubernetes {
          yaml '''
            apiVersion: v1
            kind: Pod
            metadata:
              name: devops
            spec:
              containers:
                serviceAccountName: jenkins-job
              - name: devops
                workingDir: /tmp/jenkins
                image: papanin123/aws-cli-kubectl:v3
                resources:
                  requests:
                    memory: "1Gi"
                    cpu: "1"
                  limits:
                    memory: "2Gi"
                    cpu: "2"
                imagePullPolicy: Always
                command:
                - cat
                tty: true
          '''
        }
      }
      steps {
        container('devops') {
          sh '''
            kubectl create secret docker-registry ecr-secret \
              --docker-server=${ECR_SERVER_NAME} \
              --docker-username=AWS \
              --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
              --namespace jenkins \
              --dry-run=client -o yaml | kubectl apply -f -
          '''
        }
      }
    }
    stage('Deploy to K3S cluster') {
      agent {
        kubernetes {
          yaml '''
            apiVersion: v1
            kind: Pod
            metadata:
              name: devops
            spec:
              containers:
              - name: helm
                workingDir: /tmp/jenkins
                image: alpine/helm:3.18.0
                command:
                - sleep
                args:
                - "infinity"
          '''
        }
      }
      steps {
        container('helm') {
          withCredentials([file(credentialsId: 'k3s-config', variable: 'KUBECONFIG')]) {
            sh '''
                helm upgrade --install flask-app ./helm -n jenkins
            '''
          }
        }
      }
    }
  }
}
