## Task 5 documentation

Application docker image build and push to ECR private repository by Jenkins job

### Application deployment to K3S by using Helm.

## Prepare the Cluster
1. **Create Namespace:**

    ```bash
    kubectl create namespace test
    ```
2. **Create secret for ECR authentication.**

    ```bash
    kubectl create secret docker-registry regcred \
            --docker-server=https://<your-ecr-url> \
            --docker-username=<your-ecr-username> \
            --docker-password=<your-ecr-password> \
            --docker-email=<your-email>
    ```
3. **Deploy Application using Helm**

    ```bash
    helm upgrade --install flask-app ./helm
    ```

2. **Verify WordPress installation:**

    ```bash
    kubectl get pods -n test
    kubectl get deployments -n test
    kubectl get services -n test
    ```
    Ensure all pods are running.

3. **Visit Application in the browser**
    Application exposed by traefik ingress controller on k3S cluster and nginx reverse proxy on Bastion host that forwards traffic to the application.

    Due absent public domain name need to add to your hosts file this text:
    ```
    <bastionhostIP> flask-app.panin.lab
    ```
    # for HTTP
    http://flask-app.panin.lab
    [image](https://raw.githubusercontent.com/SerPapanin/rsschool-devops-jenkins/refs/heads/main/screenshots/http_access.png)

## Clean Up
