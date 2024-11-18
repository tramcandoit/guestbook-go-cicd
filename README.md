## Guest Book Instruction

**1. Prepare Docker Image**
- This step can be done outside the Minikube
- Build the Docker image for Guestbook:
```bash
docker build -t guestbook .
```
- Push that Docker image to a repository (my case is ECR). Please follow instruction in the ECR repository console, really easy. Don't forget to configure AWS credentials in advance

**2. Clone this Github repository**
- From this step, run command inside the Minikube
- Modify your actual Docker image in **guestbook-depl.yaml**
```bash
cd guestbook-go-cicd
```

**3. Apply Kubernetes manifests**
- Firstly, configure AWS Credentials in Minikube. You can see you configuration will be store in ***~/.aws/credentials** file
- As you can see in **.yaml** file, we need these secret or volumes: **aws-secret**, **ecr-secret**. So let's prepare it
```bash
kubectl create secret docker-registry ecr-secret --docker-server=<your-account-id>.dkr.ecr.ap-southeast-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password) --namespace=default

cd ~/.aws
kubectl create secret generic aws-secret --from-file=credentials
```
- Let's apply all the manifests

```bash
kubectl apply -f guestbook-depl.yaml
kubectl apply -f guestbook-service.yaml
kubectl apply -f redis-master-depl.yaml
kubectl apply -f redis-master-service.yaml
```
- For trouble shooting, you can use some commmon commands such as:
```bash
kubectl logs...
kubectl describe...
```
- The guestbook will listen on port 3000
- You can see that, guestbook service is a NodePort 30010. So let's expose it! 
- Firstly, check your Minikube's IP; in my case it is **192.168.49.2**
```bash
minikube ip
```
- Check guestbook's content:
```bash
curl http://<minikube-ip>:30010
```

**4. Configure Nginx**
- Install Nginx right on the Minikube (I know it's not a best practice but I use this method for easy testing), then configure the proxy
```bash
sudo nano /etc/nginx/nginx.conf
```
- Add this block to **nginx.conf** file:
```
server {
  listen 80;
  server_name <public IP of Instance>;

  location / {
    proxy_pass http://<minikube-ip>:30010;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    # Forward cookies correctly for session handling
    proxy_set_header Cookie $http_cookie;
  }
}
```
- Run some command to make sure Nginx always up:
```bash
sudo systemctl restart nginx
sudo systemctl enable nginx
```

> From now, you can access the Guestbook web UI (which run inside Minikube) via public IP of the EC2 instance