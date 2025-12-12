# How to Run the Canary Experiment

Quick guide for team members to test the A4 continuous experimentation setup.

## Prerequisites

- Vagrant and VirtualBox installed
- `istioctl` installed
- Hosts file configured (see below)

## Step 1: Start the Cluster

```bash
cd operation/k8s
vagrant up
vagrant ssh ctrl
cd /vagrant
ansible-playbook playbooks/node.yaml --ask-pass
# Password: vagrant
```

Verify nodes are ready:
```bash
kubectl get nodes
# Should show: ctrl, node-1, node-2 all Ready
```

## Step 2: Deploy the Application

```bash
# Install the Helm chart
helm install team8-app ./team8-app

# Install Prometheus + Grafana
helm repo add prom-repo https://prometheus-community.github.io/helm-charts
helm repo update
helm install myprom prom-repo/kube-prometheus-stack --timeout 10m
```

Wait for pods to be ready:
```bash
kubectl get pods
# All pods should show Running
```

## Step 3: Configure Hosts File

Add to your hosts file:
- **Windows**: `C:\Windows\System32\drivers\etc\hosts`
- **Mac/Linux**: `/etc/hosts`

```
192.168.56.91  team8.local
192.168.56.91  grafana.team8.local
192.168.56.91  prometheus.team8.local
```

## Step 4: Configure Grafana Datasource

1. Open Grafana: `http://grafana.team8.local`
2. Login:
   - Username: `admin`
   - Password: Run `kubectl get secret myprom-grafana -o jsonpath='{.data.admin-password}' | base64 --decode`
3. Go to **Connections** → **Data sources** → **Add data source**
4. Select **Prometheus**
5. Set URL: `http://myprom-kube-prometheus-sta-prometheus.default.svc.cluster.local:9090`
6. Click **Save & test**

## Step 5: Generate Traffic

```bash
# Send 100 requests (90% go to stable, 10% to canary)
for i in {1..100}; do
  curl -s -X POST http://team8.local/sms \
    -H "Content-Type: application/json" \
    -d '{"sms": "Congratulations! You won a free iPhone"}'
  echo " - Request $i"
done
```

Send the same message again to trigger cache hits:
```bash
for i in {1..100}; do
  curl -s -X POST http://team8.local/sms \
    -H "Content-Type: application/json" \
    -d '{"sms": "Congratulations! You won a free iPhone"}'
  echo " - Request $i"
done
```

## Step 6: View the Dashboard

1. Open Grafana: `http://grafana.team8.local`
2. Go to **Dashboards** → **Canary Experiment Dashboard**
3. Set time range to **Last 15 minutes**
4. Click **Refresh**

## What You Should See

| Panel | Expected Result |
|-------|-----------------|
| Traffic Split | ~90% Stable, ~10% Canary |
| Request Rate | Both versions receiving traffic |
| Latency Comparison | Canary (v2) much faster due to caching |
| Total Requests | Stable has ~10x more requests than Canary |

## Verify in Prometheus

Open `http://prometheus.team8.local` and query:

```
app_sms_requests_total
```

Should show metrics with `version="stable"` and `version="canary"` labels.

## Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| No data in Grafana | Check datasource is configured correctly |
| No version labels | Ensure latest app-service image is deployed |
| Pods not running | Run `kubectl get pods` and check logs |
| Can't access URLs | Verify hosts file and port forwarding |

## Minikube Alternative

If using Minikube instead of Vagrant:

```bash
minikube start --memory=4096 --cpus=4 --driver=docker
minikube addons enable ingress
istioctl install -y

# Deploy app and monitoring (same as above)
helm install team8-app ./team8-app
helm install myprom prom-repo/kube-prometheus-stack --timeout 10m

# Port forward
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

Then use `localhost:8080` with Host header:
```bash
curl -s -X POST http://localhost:8080/sms \
  -H "Host: team8.local" \
  -H "Content-Type: application/json" \
  -d '{"sms": "Test message"}'
```
