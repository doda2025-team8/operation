# How to Run the Canary Experiment

Quick guide to run the experiment.

## Prerequisites

- A minikube deployment with istio enabled setup according to the README.
- Or a VirtualBox deployment with istio setup according to the README.
- A correct /etc/hosts file (also described in the README)

## Step 1: Configure Grafana Datasource

1. Open Grafana: `http://grafana.team8.local`
2. Login:
   - Username: `admin`
   - Password: Run `kubectl get secret team8-app-grafana -o jsonpath='{.data.admin-password}' | base64 --decode`
3. Go to **Connections** → **Data sources** → **Add data source**
4. Select **Prometheus**
5. Set URL: `http://team8-app-kube-prometheus-sta-prometheus.default.svc.cluster.local:9090`
6. Click **Save & test**

## Step 2: Generate Traffic manually

The experiment is designed based on real user traffic. When a user without a canary-user cookie access the application, Istio decides with a 90/10 rule if they should be in the canary group or not. This is then enforced for further requests by letting the app-frontend set a cookie `canary-user=true/false`. For this reason, when manually generating traffic, we chain the request to `app-service` after a request to `app-frontend`

```bash
# Send 100 requests (90% go to stable, 10% to canary)
for i in {1..100}; do
  # Load and save the canary-user cookie
  curl -c cookie.tmp -s http://team8.local/ > /dev/null
  # Request with cookie
  curl -b cookie.tmp -s -X POST http://team8.local/sms \
    -H "Content-Type: application/json" \
    -d '{"sms": "Congratulations! You won a free iPhone"}'
  echo " - Request $i"
  rm cookie.tmp
done
```

## Step 3: View the Dashboard

1. Open Grafana: `http://grafana.team8.local`
2. Go to **Dashboards** → **Canary Experiment Dashboard**
3. Set time range to **Last 15 minutes**
4. Click **Refresh**

## What You Should See

| Panel              | Expected Result                           |
| ------------------ | ----------------------------------------- |
| Traffic Split      | ~90% Stable, ~10% Canary                  |
| Request Rate       | Both versions receiving traffic           |
| Latency Comparison | Canary (v2) much faster due to caching    |
| Total Requests     | Stable has ~10x more requests than Canary |

## Verify in Prometheus

Open `http://prometheus.team8.local` and query:

```
app_sms_requests_total
```

Should show metrics with `version="stable"` and `version="canary"` labels.

## Quick Troubleshooting

| Issue              | Solution                                    |
| ------------------ | ------------------------------------------- |
| No data in Grafana | Check datasource is configured correctly    |
| No version labels  | Ensure latest app-service image is deployed |
| Pods not running   | Run `kubectl get pods` and check logs       |
| Can't access URLs  | Verify hosts file and port forwarding       |
