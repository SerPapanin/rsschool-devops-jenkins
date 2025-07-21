# Task 6: Application Deployment via Jenkins Pipeline

The pipeline is designed to automate the build, test, and deployment phases, ensuring a reliable and repeatable deployment process.

## Prerequisites
1. Jenkins Setup:

- Jenkins server with required plugins:
    - Pipeline
    - Kubernetes
    - Email Extension or Mailer (for notifications)
    - Git
    - SonarQube
- Jenkins nodes configured with necessary tools (e.g., Docker, Node.js).
2. SonarQube:

- Need to insyall and configure SonarQube server.
- Need to create a project in SonarQube for the application.
3. Deployment Environment:

- Kubernetes cluster or K3S or minikube.
4. Credentials:

- AWS role attached to Jenkins host to access AWS ECR repository.
- Kubernetes access credentials.
- SMTP server credentials for email notifications.

## Pipeline Overview
The Jenkins pipeline includes the following stages:

1. Clone Repository:

- Fetch the latest code from the repository.
2. Docker Image Build:

- Install dependencies and build docker image.
- Push docker image to ECR registry.
4. Static Code Analysis:

- Use tools like SonarQube to analyze code quality and enforce standards.
5. Deploy to Kubernetes:

- Use Helm to deploy the application to a Kubernetes cluster.
- Update existing deployments or create new ones.

6. Notifications:

- Send email notifications on success or failure.

## How to Use
1. Configure Jenkins Job:

- Create a Jenkins job and choose "Pipeline" as the job type.
- Add the link to a Jenkinsfile in your repository.
2. Set Up Kubernetes and Jenkins:

- Ensure your Kubernetes cluster is accessible.
- Create Jenkins credentials for Kubernetes access and SonarQube access.
3. Test the Pipeline:

- Run the pipeline to ensure it works as expected.
- Monitor logs for any errors during the build or deployment.
4. Deploy Application:

- Trigger the pipeline manually or set up automatic triggers (e.g., webhooks).
