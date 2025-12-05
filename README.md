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


## Setup Instructions

### 1. Create and provision VMs
```bash
vagrant up
```

### 2. Join worker nodes to cluster
After all VMs are running, SSH into the controller and run the join playbook:
```bash
vagrant ssh ctrl
cd /vagrant
ansible-playbook playbooks/node.yaml --ask-pass
```
Password: `vagrant`

### 3. Verify cluster
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

### 4. Finalize Cluster Services
```bash
ansible-playbook -i k8s/inventory/hosts.ini k8s/playbooks/finalization.yml -u vagrant
```

### 4. Add Prometheus + Grafana dependencies
```bash
vagrant ssh ctrl
helm repo add prom-repo https://prometheus-community.github.io/helm-charts
helm repo update
helm install myprom prom-repo/kube-prometheus-stack --timeout 10m

```

### 5. Install Applications

Deploy application chart (app-frontend, app-service, model-service, and ingress) to the Kubernetes cluster using Helm:

```bash
   vagrant ssh ctrl
   helm install team8-app /home/vagrant/team8-app
```

### 6. Access Prometheus website

```
$ kubectl port-forward svc/myprom-kube-prometheus-sta-prometheus 9090:9090
```
 The app exposes the following 3 metrics at **/actuator/prometheus**:

 * `app_sms_requests_total`: a count to count the total number of SMS prediction requests received
 * `app_sms_active_requests`: a gauge that shows how many SMS requests are currently being processed
 * `app_sms_latency_seconds`: a timer that measures how long it takes to process an SMS prediction request

### 6. Access Grafana Dasboards

Verify dashboard ConfigMap was created
```bash
kubectl get configmap | grep grafana
```

Port forward Grafana
```bash
kubectl port-forward svc/myprom-grafana 3000:80 --address 0.0.0.0
```

Open browser: http://localhost:3000
Login credentials:

Username: admin
Password: run in another terminal:
```bash
vagrant ssh ctrl -c "kubectl get secret myprom-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
```

### Access
1. **Add the following lines to your host machine's /etc/hosts file:** 
```bash
# K8s Cluster Services
192.168.56.91  dashboard.local
192.168.56.91  app.local
```
2. **Access Kubernetes Dashboard**
- Open your browser and navigate to: https://dashboard.local

- Ignore the self-signed certificate warning (proceed to the site).

- Use the Token displayed in the terminal output of the finalization.yml run (e.g., the output of the Display Admin User Token task) to log in.

# Install app with Helm

## Prerequisites

* Make sure you have your docker engine running
* Start minikube `minikube start --driver=docker`
* Enable minikube ingress `minikube addons enable ingress`

## Helm install

* `cd` into `operation` (this repository)
* Execute `helm install team8-app ./team8-app`
* Container creation takes appprox. 20 sec

## Validate

* `kubectl get pods` should give you three `Running` pods:
   * `model-service`
   * `app-frontend`
   * `app-service`
* `kubectl get ingress` should show an `app-ingress` is running. By navigating to its IP address in your browser, you should see the running app and use it.

## Configuring the hostname

* By default, the frontend will run on a hostname `team8.local`, you should map this to your minikube IP by running `echo "$(minikube ip)  team8.local" | sudo tee -a /etc/hosts`.
* This should allow you to navigate to https://team8.local and use the app from there

# How to access Prometheus 

### 1. Add the Prometheus repository

```
$ helm repo add prom-repo https://prometheus-community.github.io/helm-charts
$ helm repo update
```

### 2. Install Prometheus Stack

```
$ helm install myprom prom-repo/kube-prometheus-stack
```

### 3. Port forward to access Prometheus website

```
$ kubectl port-forward svc/myprom-kube-prometheus-sta-prometheus 9090:9090
```
 The app exposes the following 3 metrics at **/actuator/prometheus**:

 * `app_sms_requests_total`: a count to count the total number of SMS prediction requests received
 * `app_sms_active_requests`: a gauge that shows how many SMS requests are currently being processed
 * `app_sms_latency_seconds`: a timer that measures how long it takes to process an SMS prediction request
## Grafana Dashboards

### Automatic Installation

Dashboards are automatically installed via ConfigMap when deploying with Helm. The ConfigMap is labeled with `grafana_dashboard: "1"` for automatic discovery by Grafana's sidecar.

### Manual Import (if needed)

If dashboards don't appear automatically:

1. Access Grafana UI (default: http://localhost:3000)
2. Go to **Dashboards** → **New** → **Import**
3. Click **Upload JSON file**
4. Upload JSON files from `team8-app/dashboards/`:
   - `app-metrics.json` - SMS App monitoring metrics
   - `experiment-dashboard.json` - Canary release comparison (A4)
5. Select the Prometheus datasource when prompted
6. Click **Import**
