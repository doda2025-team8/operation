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
  - [Setup Instructions Kubernetes](#setup-instructions-kubernetes)
    - [Vagrant](#vagrant)
    - [Minikube](#minikube)
- [How to install with helm](#how-to-install-with-helm)
  - [1 Add Istio (Only on Minikube)](#1-add-istio-only-on-minikube)
  - [2. Install Applications](#2-install-applications)
  - [2.1 Ingress Gateway Configuration](#21-ingress-gateway-configuration)
  - [2.2 AlertManager Configuration (Email Alerts)](#22-alertmanager-configuration-email-alerts)
  - [3. Validate install](#3-validate-install)
    - [Automatic Installation](#automatic-installation)
    - [Manual Import (if needed)](#manual-import-if-needed)
  - [4. Access applications](#4-access-applications)
    - [1a. Access for Minikube](#1a-access-for-minikube)
    - [1b. Vagrant cluster](#1b-vagrant-cluster)
    - [2. Access Prometheus website](#2-access-prometheus-website)
    - [3. Access Grafana Dashboards](#3-access-grafana-dashboards)
    - [4. Access Kubernetes Dashboard (only on Vagrant)](#4-access-kubernetes-dashboard-only-on-vagrant)
- [Traffic Management & Testing](#traffic-management--testing)
  - [Accessing the Canary Release Directly](#accessing-the-canary-release-directly)
  - [Testing Approach](#testing-approach)
    - [Verify Traffic Split (90/10)](#verify-traffic-split-9010-check-the-number-of-v1-and-v2)
    - [Verify Consistent Routing](#verify-consistent-routing)
- [Additional Use Case - Shadow launch](#aditional-use-case---shadow-launch)
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

   #### Supporting Arguments:

   #### Image versions
   - `MODEL_SERVICE_VERSION` - version tag of model-service image
   - `APP_SERVICE_VERSION` - version tag of app-service image 
   - `APP_FRONTEND_VERSION` - version tag of app-frontend image

   #### Internal service ports
   - `APP_SERVICE_PORT` - internal port on which app-service listens
   - `APP_FRONTEND_PORT` - internal port on which app-frontend listens

   #### NGINX_PORT
   - `NGINX_PORT` - internal port used by NGINX to route traffic

   #### Exposed port on localhost
   - `EXPOSED_PORT` - port exposed on localhost tor accessing the application

   #### MODEL SERVICE location
   - `MODEL_HOST` - hostname on where the model service is reachable
   - `MODEL_SERVICE_PORT` - service port
   - `MODEL_DIR` - model directory
   - `MODEL_VERSION` - released model version
   - `GITHUB_REPO`- repository for downloading the model

## Setup Instructions Kubernetes

There are two ways to run the applications on kubernetes. The first one is to run the application on cluster provisioned with Vagrant and the second way is to use minikube.

Add the following lines to your host machine's `/etc/hosts` file if you want the hostnames to work.

For Linux/macOS: `/etc/hosts`
For Windows: `C:\Windows\System32\drivers\etc\hosts`

```bash
# K8s Cluster Services (Vagrant cluster - use 192.168.56.91)
192.168.56.91  team8.local
192.168.56.91  canary.team8.local
192.168.56.91  grafana.team8.local
192.168.56.91  prometheus.team8.local
192.168.56.91  dashboard.local

# For Minikube, use 127.0.0.1 instead:
# 127.0.0.1  team8.local
# 127.0.0.1  canary.team8.local
# 127.0.0.1  grafana.team8.local
# 127.0.0.1  prometheus.team8.local
```

### Vagrant

1. Create and provision VMs
   ```bash
   cd k8s/
   vagrant up
   ```

2. Verify cluster   
   2.1 SSH into the controller  
   ```bash
   vagrant ssh ctrl
   kubectl get nodes -o wide
   ```

   2.2 From host
   ```bash
   KUBECONFIG=./admin.conf  kubectl get nodes -o wide
   ```

   Expected output:
   ```
   NAME     STATUS   ROLES           AGE   VERSION
   ctrl     Ready    control-plane   XXm   v1.32.4
   node-1   Ready    <none>          XXm   v1.32.4
   node-2   Ready    <none>          XXm   v1.32.4
   ```

3. Finalize Cluster Services
   ```bash
   ansible-playbook -i k8s/inventory/hosts.ini k8s/playbooks/finalization.yml -u vagrant
   ```

4. Use the `k8s/shared` folder to include extra images that can be served by the `app-frontend`. The files will be visible at `http://team8.local/shared/<filename>`

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

## 1 Add Istio (Only on Minikube)

Download Istio from the official website

```bash
istioctl install
kubectl label namespace default istio-injection=enabled
```

## 2. Install Applications

Deploy the dependiencies (grafana and prometheus) and application chart (app-frontend, app-service, model-service and ingress) to the Kubernetes cluster using Helm.

In `values.yaml`, istio can be enabled or disabled.

On Vagrant:
```bash
vagrant ssh ctrl # Only with vagrant
helm install team8-app /home/vagrant/team8-app --dependency-update
```

On Minikube:
```bash
helm install team8-app ./team8-app --dependency-update
```
Container creation takes appprox. 20 sec

## 2.1 Ingress Gateway Configuration

We use Istio for traffic management. The gateway selector is set in `values.yaml`:

```yaml
istio:
  ingressGatewaySelector:
    istio: ingressgateway
```

This works out of the box with the default Istio setup. If your cluster uses a different gateway name, override it like this:

```bash
helm install team8-app ./team8-app --dependency-update --set istio.ingressGatewaySelector.istio=my-custom-gateway
```

You can also change the hostnames if needed:

```yaml
rechability:
  hostname: "team8.local"           # Main application
  canaryHostname: "canary.team8.local"  # Direct canary access
  grafanaHostname: "grafana.team8.local"
  prometheusHostname: "prometheus.team8.local"
```

## 2.2 AlertManager Configuration (Email Alerts)

To get email alerts working, edit `values.yaml` with your email credentials:

```yaml
alertmanager:
  email:
    to: "your-receiver@example.com"      # who gets the alert
    from: "your-sender@example.com"      # sender address
    smarthost: "smtp.gmail.com:587"      # SMTP server:port
    authUsername: "your-email@gmail.com" # SMTP login
    authPassword: "your-app-password"    # SMTP password
    requireTLS: true
```

**Gmail users:** You'll need to create an [App Password](https://support.google.com/accounts/answer/185833) since regular passwords won't work.

The alert fires when the app gets more than 15 requests/min for 2 minutes (see `prometheusrule.yaml`).

## 3.  Validate install

* `kubectl get pods` should give you three `Running` pods:
   * `model-service`
   * `app-frontend-v1`
   * `app-frontend-v2`
   * `app-service`
* `kubectl get ingress` should show an `app-ingress` is running. By navigating to its IP address in your browser, you should see the running app and use it.
* `kubectl get pods -n istio-system` should show you that Istio is running.
* Run `istioctl dashboard kiali` to see the details of Istio and how its running.

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

### 1a. Access for Minikube

**Option 1: `minikube tunnel` (Recommended)**

Open a new terminal and run (needs admin/sudo):

```bash
minikube tunnel
```

Keep it running. Now with your `/etc/hosts` pointing to `127.0.0.1`, just open:
- App: `http://team8.local`
- Canary: `http://canary.team8.local`
- Grafana: `http://grafana.team8.local`
- Prometheus: `http://prometheus.team8.local`

**Option 2: port-forward**

If tunnel doesn't work for you:

```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

Or without Istio:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

Then add `:8080` to all URLs:
- App: `http://team8.local:8080`
- Canary: `http://canary.team8.local:8080`
- Grafana: `http://grafana.team8.local:8080`
- Prometheus: `http://prometheus.team8.local:8080`

### 1b. Vagrant cluster

On Vagrant, MetalLB gives the Istio gateway a fixed IP (`192.168.56.91`), so no port-forwarding needed. Just make sure your `/etc/hosts` is set up and go to:

- App: `http://team8.local`
- Canary: `http://canary.team8.local`
- Grafana: `http://grafana.team8.local`
- Prometheus: `http://prometheus.team8.local`
- K8s Dashboard: `https://dashboard.local`

### 2. Access Prometheus

With tunnel/Vagrant: `http://prometheus.team8.local`
With port-forward: `http://prometheus.team8.local:8080`

(Prometheus runs on port 9090 internally, but Istio routes it through port 80)

**App-service metrics** at `/sms/metrics`:

| Metric | Type | What it tracks |
|--------|------|----------------|
| `app_sms_requests_total` | Counter | Total SMS predictions |
| `app_sms_active_requests` | Gauge | Currently processing |
| `app_sms_latency_seconds` | Histogram | Processing time |
| `app_cache_hits_total` | Counter | Cache hits (v2 only) |
| `app_cache_misses_total` | Counter | Cache misses (v2 only) |

All metrics have a `version` label (`stable`/`canary`) for filtering.

**Model-service metrics** at `/metrics`:

| Metric | Type | What it tracks |
|--------|------|----------------|
| `model_predictions_total` | Counter | Total predictions |
| `model_prediction_latency_seconds` | Histogram | Prediction time |

### 3. Access Grafana Dashboards

Check that the dashboard configmap exists:
```bash
kubectl get configmap | grep grafana
```

Go to `http://grafana.team8.local` (or `:8080` with port-forward)

**Login:**
- Username: `admin`
- Password: get it with:

For vagrant:
```bash
vagrant ssh ctrl -c "kubectl get secret team8-app-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
```

For minikube:
```bash
kubectl get secret myprom-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
```

### 4. Access Kubernetes Dashboard (Vagrant only)

Make sure `dashboard.local` points to `192.168.56.91` in your `/etc/hosts`.

1. Go to `https://dashboard.local`
2. You'll get a certificate warning - just click through it (self-signed cert)
3. Pick "Token" login
4. Get a token:
   ```bash
   # from your host machine
   KUBECONFIG=./k8s/admin.conf kubectl -n kubernetes-dashboard create token admin-user

   # or from inside the VM
   vagrant ssh ctrl -c "kubectl -n kubernetes-dashboard create token admin-user"
   ```
5. Paste it and log in

# Traffic Management & Testing
We have implemented a Canary Release strategy using Istio. The deployment features a 90/10 traffic split (90% stable, 10% canary) with Sticky Sessions for user stability and Strict Consistency to ensure version alignment across microservices (app-front v1 → app-service v1 → model-service v1).

## Accessing the Canary Release Directly

If you want to skip the 90/10 split and hit the canary (v2) directly:

**Using the canary hostname:**
```bash
curl http://canary.team8.local/sms -X POST -H "Content-Type: application/json" -d '{"sms": "test message"}'
```
(make sure `canary.team8.local` is in your `/etc/hosts`)

**Using a cookie:**
```bash
curl http://team8.local/sms -X POST -H "Content-Type: application/json" -H "Cookie: canary-user=true" -d '{"sms": "test message"}'
```

The canary hostname can be changed in `values.yaml` under `rechability.canaryHostname`.

## Testing Approach
### Verify Traffic Split (90/10): Check the number of v1 and v2
```
for i in {1..20}; do
  echo "Request $i:"
  curl -s -X POST http://team8.local/sms\
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

   If you cannot see the logs of all pods, add the `--max-log-requests=10` argument to the commands above.

2. Send a request in a new terminal:
   ```
   curl -v -X POST http://team8.local/sms -H "Content-Type: application/json"   -d '{"sms": "test shadow launch"}'
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
