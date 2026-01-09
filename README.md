# DODA 2025-2026 Team 8 - Operation

This repository is the home of the submission for the project of Team 8 in the course *CS4295 Development and Operation of Distributed Applications* as taught at [Delft University of Technology](https://www.tudelft.nl/) in the academic year 2025-2026.

## Table of Contents

- [DODA 2025-2026 Team 8 - Operation](#doda-2025-2026-team-8---operation)
  - [Table of Contents](#table-of-contents)
  - [Structure](#structure)
- [How to run](#how-to-run)
  - [Docker Compose](#docker-compose)
    - [Prerequisites](#prerequisites)
    - [Starting the application](#starting-the-application)
    - [Adjust the environment variables](#adjust-the-environment-variables)
    - [Files in this repository:](#files-in-this-repository)
  - [Kubernetes](#kubernetes)
    - [Vagrant](#vagrant)
    - [Minikube](#minikube)
- [How to install with helm](#how-to-install-with-helm)
  - [1. Install Applications](#1-install-applications)
  - [2.  Validate install](#2--validate-install)
  - [3. Add Prometheus + Grafana dependencies](#3-add-prometheus--grafana-dependencies)
    - [Automatic Installation](#automatic-installation)
    - [Manual Import (if needed)](#manual-import-if-needed)
  - [4. Access applications](#4-access-applications)
    - [1a. Port forward for Minikube](#1a-port-forward-for-minikube)
    - [1b. Vagrant cluster](#1b-vagrant-cluster)
    - [2. Access Prometheus website](#2-access-prometheus-website)
    - [3. Access Grafana Dasboards](#3-access-grafana-dasboards)
    - [4. Access Kubernetes Dashboard (only on Vagrant)](#4-access-kubernetes-dashboard-only-on-vagrant)
- [Traffic Management \& Testing](#traffic-management--testing)
  - [Testing Approach](#testing-approach)
    - [Verify Traffic Split (90/10): Check the number of v1 and v2](#verify-traffic-split-9010-check-the-number-of-v1-and-v2)
    - [Verify Consistent Routing](#verify-consistent-routing)
- [Aditional Use Case - Shadow launch](#aditional-use-case---shadow-launch)
  - [Testing Approach](#testing-approach-1)


## Structure 

The application consists of four components, each in its own repository:

| Component       | Description                                                                    |
|---------------|--------------------------------------------------------------------------------|
| [app-frontend](https://github.com/doda2025-team8/app-frontend)  | The UI (HTML/JS) of the application served through nginx.                              |
| [app-service](https://github.com/doda2025-team8/app-service)   | An API gateway for forwarding requests to the model-service via REST. |
| [model-service](https://github.com/doda2025-team8/model-service) | It serves the ML model for spam detection prediction.  |
| [lib-version](https://github.com/doda2025-team8/lib-version) | A version-aware package that is used by the app-service with no specific functionality.  |

The repositories are a fork of the [SMS Checker Application](https://github.com/proksch/sms-checker) made by [Sebastian Proksch](https://github.com/proksch).

# How to run

This app can be run and installed in various different ways. Make sure you choose a manner that is most applicable for your situation. 

Make sure you have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed. Often this is done easiest by installing the [Docker Engine](https://docs.docker.com/engine/).

## Docker Compose

### Prerequisites 

Make sure your Docker instance is running.

### Starting the application

1. Start the application
```
docker compose up -d
```
2. Access the application
   
   Open your browser and navigate to:
```
   http://localhost:8080
```

### Adjust the environment variables

If you want, you can change the variables as defined in the [`.env`](https://github.com/doda2025-team8/operation/blob/main/.env) file.

### Files in this repository:

- **`docker-compose.yml`**: Defines and orchestrates all services required to run the application
- **`nginx.conf`**: Configuration file for the Nginx reverse proxy
- **`.env`**: Environment-specific configuration 


## Kubernetes

There are two ways to run the applications on kubernetes. The first one is to run the application on cluster provisioned with Vagrant and the second way is to use minikube.

Add the following lines to your host machine's `/etc/hosts` file if you want the hostnames to work.
```bash
# K8s Cluster Services
192.168.56.91  team8.local
192.168.56.91  grafana.team8.local
192.168.56.91  prometheus.team8.local
```

### Vagrant

1. Create and provision VMs
```bash
cd k8s/
vagrant up
```

2. Join worker nodes to cluster
After all VMs are running, SSH into the controller and run the join playbook:
```bash
vagrant ssh ctrl
cd /vagrant
ansible-playbook playbooks/node.yaml -i inventory/hosts.ini --ask-pass
```
Might need to run: 
`ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/node.yaml -i inventory/hosts.ini --ask-pass`
Password: `vagrant`

3. Verify cluster
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

4. Finalize Cluster Services
```bash
ansible-playbook -i k8s/inventory/hosts.ini k8s/playbooks/finalization.yml -u vagrant
```

### Minikube

1. Clear previous installs
```bash
minikube delete
```

2. Install. Make sure you have your docker engine running.
```bash
minikube start --memory=4096 --cpus=4 --driver=docker # start minikube
minikube addons enable ingress # enable ingress
```

# How to install with helm

Make sure you have [Kubernetes](https://kubernetes.io/) and [helm](https://helm.sh/) installed.

## 1. Install Applications

Deploy application chart (app-frontend, app-service, model-service, and ingress) to the Kubernetes cluster using Helm:

On Vagrant:
```bash
vagrant ssh ctrl # Only with vagrant
helm install team8-app /home/vagrant/team8-app
```

On Minikube:
```bash
helm install team8-app ./team8-app
```
Container creation takes appprox. 20 sec

## 2.  Validate install

* `kubectl get pods` should give you three `Running` pods:
   * `model-service`
   * `app-frontend-v1`
   * `app-frontend-v2`
   * `app-service`
* `kubectl get ingress` should show an `app-ingress` is running. By navigating to its IP address in your browser, you should see the running app and use it.
* `kubectl get pods -n istio-system` should show you that Istio is running.
* Run `istioctl dashboard kiali` to see the details of Istio and how its running.

## 3. Add Prometheus + Grafana dependencies

```bash
vagrant ssh ctrl # Only on vagrant
helm repo add prom-repo https://prometheus-community.github.io/helm-charts
helm repo update
helm install myprom prom-repo/kube-prometheus-stack --timeout 10m
```

### Automatic Installation

Dashboards are automatically installed via ConfigMap when deploying with Helm. The ConfigMap is labeled with `grafana_dashboard: "1"` for automatic discovery by Grafana's sidecar.

### Manual Import (if needed)

If dashboards don't appear automatically:

1. Access Grafana UI (see below)
2. Go to **Dashboards** → **New** → **Import**
3. Click **Upload JSON file**
4. Upload JSON files from `team8-app/dashboards/`:
   - `app-metrics.json` - SMS App monitoring metrics
   - `experiment-dashboard.json` - Canary release comparison (A4)
5. Select the Prometheus datasource when prompted
6. Click **Import**

## 4. Access applications

To access the applications, you need to be able to access the ingress

### 1a. Port forward for Minikube
```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 
```
- The application can now be accessed on `http://team8.local:8080`
- Grafana on `http://grafana.team8.local:8080`
- Prometheus on `http://prometheus.team8.local:8080`

### 1b. Vagrant cluster
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

# Aditional Use Case - Shadow launch
A second instance of the model-service (v3) is deployed which uses a new version of the model (v1.0.2) and is used to mirror existing traffic to the other two instanses v1 and v2.

## Testing Approach
Steps:
1. Open two terminals to tail logs for v1 and v3 separately:

   ```
   # Terminal A
   kubectl logs -f -l version=v1 --all-containers=true

   # Terminal B
   kubectl logs -f -l version=v3 --all-containers=true
   ```
2. Send a request in a new terminal:
   ```
   curl -v -X POST http://localhost:8080/sms   -H "Host: team8.local"   -H "Content-Type: application/json"   -d '{"sms": "test shadow launch"}'
   ```
3. Inspoect the logs. 
   * You will see that v1 processes the request and returns an output.
   * v3 receives the mirrored request internally but does not output anything.
4. Metrics are exposed in model-service to evaluate the new model version. 
   * `model_predictions_total`
   * `model_prediction_latency_seconds`

   To acess the metrics run:
   ```
   kubectl port-forward $(kubectl get pods | grep model-service-v3 | awk '{print $1}') 8082:8081
   ```
   Navigate to `http://localhost:8082/metrics`


