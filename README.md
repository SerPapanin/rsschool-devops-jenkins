## Task 5 documentation

Application docker image build and push the application to ECR private repository by Jenkins job

### Application deployment to K3S by using Helm.
1. Need to prepare cluster for deployment.
2. Create namespace for application deployment.
```
kubectl create namespace test
```
3. Create secret for ECR authentication.
```
kubectl create secret docker-registry regcred \
--docker-server=https://<your-ecr-url> \
--docker-username=<your-ecr-username> --docker-password=<your-ecr-password> --docker-email=<your-email>
```
4. Deploy application by Helm chart.
```
helm upgrade --install flask-app ./helm
```
