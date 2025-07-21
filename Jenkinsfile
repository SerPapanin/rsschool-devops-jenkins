pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          name: service_pod
        spec:
          serviceAccountName: jenkins-job
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
          - name: helm
            workingDir: /tmp/jenkins
            image: alpine/helm:3.18.0
            command:
            - sleep
            args:
            - "infinity"
          - name: sonar
            image: sonarsource/sonar-scanner-cli:11.3
            command:
            - sleep
            args:
            - 99d
      '''
    }
  }
  environment {
    AWS_REGION = 'us-east-1'
    AWS_ACCOUNT_ID = '837781915459'
    AWS_ECR_REPOSITORY_NAME = 'rs-school/app-cloud'
    IMAGE_TAG = 'latest'
    ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}"
    ECR_SERVER_NAME = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    AWS_ECR_PASSWORD = ''
    APP_NAMESPACE = "flask-app"
  }

  stages {
    stage('Build and Push Docker Image') {
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
    stage('SonarQube Code Scan') {
        steps {
            container('sonar') {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    sonar-scanner \
                        -Dsonar.projectKey=$SONAR_PROJECT_KEY \
                        -Dsonar.sources=./rs-school_app/src \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN \
                        -Dsonar.javascript.lcov.reportPaths=./rs-school_app/coverage/lcov.info
                    '''
                }
            }
            script {
                    echo 'SonarQube analysis completed successfully!'
            }
        }
    }
    stage('Create ECR Secret') {
      steps {
        container('devops') {
          sh '''
            kubectl create secret docker-registry ecr-secret \
              --docker-server=${ECR_SERVER_NAME} \
              --docker-username=AWS \
              --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
              --namespace ${APP_NAMESPACE} \
              --dry-run=client -o yaml | kubectl apply -f -
          '''
        }
      }
    }
    stage('Deploy to K3S cluster') {
      steps {
        container('helm') {
          withCredentials([file(credentialsId: 'k3s-config', variable: 'KUBECONFIG')]) {
            sh '''
                helm upgrade --install flask-app ./helm -n ${APP_NAMESPACE} --set namespace=${APP_NAMESPACE}
            '''
          }
        }
      }
    }
    stage('Smoke test') {
      steps {
        container('devops') {
          withCredentials([file(credentialsId: 'k3s-config', variable: 'KUBECONFIG')]) {
            sh '''
                kubectl get pods -n ${APP_NAMESPACE} -l app=flask-app -o jsonpath='{.items[0].metadata.name}' | xargs kubectl logs -n ${APP_NAMESPACE}
                curl -s -o /dev/null -w "%{http_code}" --resolve flask-app.panin.lab:80:10.1.6.225 http://flask-app.panin.lab/
            '''
          }
        }
      }
    }
  }
  post {
      success {
          script {
              mail to: 'panin.tut@gmail.com',
                   subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                   body: """
                   Build #${env.BUILD_NUMBER} of job '${env.JOB_NAME}' was successful.

                   View the details here: ${env.BUILD_URL}
                   """
          }
      }
      failure {
          script {
              mail to: 'panin.tut@gmail.com',
                   subject: "FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                   body: """
                   Build #${env.BUILD_NUMBER} of job '${env.JOB_NAME}' failed.

                   View the details here: ${env.BUILD_URL}
                   """
          }
      }
    }
}
