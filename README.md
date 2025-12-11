# SMS Checker - Operation Repository

This repository contains all information about running the SMS checker application.

### Application
The application consists of four components:

| Component       | Description                                                                    |
|---------------|--------------------------------------------------------------------------------|
| app-frontend  | The UI (HTML/JS) of the application served through nginx.                              |
| app-service   | An API gateway for forwarding requests to the model-service via REST. |
| model-service | It serves the ML model for spam detection prediction.  |
| lib-version | A version-aware package that is used by the app-service with no specific
functionality.  |

Links to repositories:

``lib-version``: https://github.com/doda2025-team8/lib-version/releases/tag/a1 \
``app-service``:  https://github.com/doda2025-team8/app-service/releases/tag/a1 \
``app-frontend``: https://github.com/doda2025-team8/app-frontend/releases/tag/a1 \
``model-service``: https://github.com/doda2025-team8/model-service/releases/tag/a1 

An NGINX reverse proxy was configured to serve the frontend and safely forward API calls to the backend from the same origin to avoid CORS issues.

## Run With Docker Compose

### How to run the application

#### Prerequisites
- Docker Engine

### Starting the application
1. **Create an .env file**   
An example .env file is provided, containing the environment variables required to run the application. You can modify it as needed.
2. **Start the application**
```
docker compose up -d
```
4. **Access the application**
   
   Open your browser and navigate to:
```
   http://localhost:8080
```

### Files in this repository:

- **`docker-compose.yml`**: Defines and orchestrates all services required to run the application
- **`nginx.conf`**: Configuration file for the Nginx reverse proxy
- **`.env`**: Environment-specific configuration 


## Setup Instructions Kubernetes

There are two ways to run the applications on kubernetes. The first one is to run the application on cluster provisioned with Vagrant and the second way is to use minikube.

### Vagrant

#### 1. Create and provision VMs
```bash
vagrant up
```

#### 2. Join worker nodes to cluster
After all VMs are running, SSH into the controller and run the join playbook:
```bash
vagrant ssh ctrl
cd /vagrant
ansible-playbook playbooks/node.yaml --ask-pass
```
Password: `vagrant`

#### 3. Verify cluster
```bash
kubectl get nodes
```

Expected output:
```
NAME     STATUS   ROLES           AGE   VERSION
ctrl     Ready    control-plane   XXm   v1.32.4
node-1   Ready    <none>          XXm   v1.32.4
node-2   Ready    <none>          XXm   v1.32.4
```

#### 4. Finalize Cluster Services
```bash
ansible-playbook -i k8s/inventory/hosts.ini k8s/playbooks/finalization.yml -u vagrant
```

#### 5.

Install istioctl

#### 6. Setup hosts file
1. **Add the following lines to your host machine's /etc/hosts file:** 
```bash
# K8s Cluster Services
192.168.56.91  team8.local
192.168.56.91  grafana.team8.local
192.168.56.91  prometheus.team8.local
```

### Minikube

#### 1. Clear previous installs
* `minikube delete`

#### 2. Install

* Make sure you have your docker engine running, also make sure you have `istioctl` installed and you have the folder `istio-1.28.1/` somewhere you can `cd` to(e.g. `Downloads/`).
* Start minikube `minikube start --memory=4096 --cpus=4 --driver=docker`
* Enable minikube ingress `minikube addons enable ingress`

#### 3. Install istioctl
* Install istio `istioctl install`
* `cd` to the directory that contains `istio-1.28.1/` and run
   * `kubectl apply -f istio-1.28.1/samples/addons/prometheus.yaml`
   * `kubectl apply -f istio-1.28.1/samples/addons/jaeger.yaml`
   * `kubectl apply -f istio-1.28.1/samples/addons/kiali.yaml`

#### 4. Setup hosts file

1. **Add the following lines to your host machine's /etc/hosts file:** 
```bash
# Minikube Services
127.0.0.1  team8.local
127.0.0.1  grafana.team8.local
127.0.0.1  prometheus.team8.local
```

## Install applications on Kubernetes cluster

### 1. Install Applications

Deploy application chart (app-frontend, app-service, model-service, and ingress) to the Kubernetes cluster using Helm:

On Vagrant:
```bash
vagrant ssh ctrl # Only with vagrant
helm install team8-app /home/vagrant/team8-app
```

On Minikube:
```bash
cd operations
helm install team8-app ./team8-app
```
Container creation takes appprox. 20 sec

#### Validate install

* `kubectl get pods` should give you three `Running` pods:
   * `model-service`
   * `app-frontend-v1`
   * `app-frontend-v2`
   * `app-service`
* `kubectl get ingress` should show an `app-ingress` is running. By navigating to its IP address in your browser, you should see the running app and use it.
* `kubectl get pods -n istio-system` should show you that Istio is running.
* Run `istioctl dashboard kiali` to see the details of Istio and how its running.

### 2. Add Prometheus + Grafana dependencies

```bash
vagrant ssh ctrl # Only on vagrant
helm repo add prom-repo https://prometheus-community.github.io/helm-charts
helm repo update
helm install myprom prom-repo/kube-prometheus-stack --timeout 10m

```
#### Automatic Installation

Dashboards are automatically installed via ConfigMap when deploying with Helm. The ConfigMap is labeled with `grafana_dashboard: "1"` for automatic discovery by Grafana's sidecar.

#### Manual Import (if needed)

If dashboards don't appear automatically:

1. Access Grafana UI (see below)
2. Go to **Dashboards** → **New** → **Import**
3. Click **Upload JSON file**
4. Upload JSON files from `team8-app/dashboards/`:
   - `app-metrics.json` - SMS App monitoring metrics
   - `experiment-dashboard.json` - Canary release comparison (A4)
5. Select the Prometheus datasource when prompted
6. Click **Import**

## Access applications

To access the applications, you need to be able to access the ingress

### 1a. Port forward for Minikube
```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 
```
- The application can now be accessed on `http://team8.local:8080`
- Grafana on `http://grafana.team8.local:8080`
- Prometheus on `http://prometheus.team8.local:8080`

### 1b Vagrant cluster
TODO

### 2. Access Prometheus website
`http://prometheus.team8.local:8080`

The app exposes the following 3 metrics at **/actuator/prometheus**:

* `app_sms_requests_total`: a count to count the total number of SMS prediction requests received
* `app_sms_active_requests`: a gauge that shows how many SMS requests are currently being processed
* `app_sms_latency_seconds`: a timer that measures how long it takes to process an SMS prediction request

### 3. Access Grafana Dasboards

Verify dashboard ConfigMap was created
```bash
kubectl get configmap | grep grafana
```

`http://grafana.team8.local:8080`

Login credentials:

Username: admin

Password: run in another terminal:

For vagrant:
```bash
vagrant ssh ctrl -c "kubectl get secret myprom-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
```

For minikube:
```bash
kubectl get secret myprom-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
```

### 4. Access Kubernetes Dashboard (only on Vagrant)
- Open your browser and navigate to: https://dashboard.local

- Ignore the self-signed certificate warning (proceed to the site).

- Use the Token displayed in the terminal output of the finalization.yml run (e.g., the output of the Display Admin User Token task) to log in.

# Traffic Management & Testing
We have implemented a Canary Release strategy using Istio. The deployment features a 90/10 traffic split (90% stable, 10% canary) with Sticky Sessions for user stability and Strict Consistency to ensure version alignment across microservices (app-front v1 → app-service v1 → model-service v1).

## Testing Approach
### Verify Traffic Split (90/10): Check the number of v1 and v2
```
for i in {1..20}; do
  echo "Request $i:"
  curl -s -X POST http://localhost/sms \
    -H "Content-Type: application/json" \
    -d '{"sms": "traffic split test"}'
done
```
### Verify Consistent Routing
Steps:
1. Open two terminals to tail logs for v1 and v2 separately:

   ```
   # Terminal A
   kubectl logs -f -l version=v1 --all-containers=true

   # Terminal B
   kubectl logs -f -l version=v2 --all-containers=true
   ```
2. Send a request using the command from Step 2.
Logs should scroll in only one terminal (either all v1 or all v2), proving that the full call chain (Frontend → Backend → Model) is version-consistent.