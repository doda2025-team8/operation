# SMS Checker - Operation Repository

This repository contains all information about running the SMS checker application.

### K8s Cluster

To set up the kubernetes cluster run k8s/script.sh

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
