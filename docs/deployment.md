# DODA 2025-2026 Team 8 - Deployment Documentation

Yanzhi Chen  
Hendrik Lambert  
Vincent Ruijgrok  
Yuchen Sun  
Andriana Tzanidou  
Horia Zaharia  

## Table of Contents

- [Introduction](#introduction)
- [Architecture Overview](#architecture-overview)
- [Deployment Structure](#deployment-structure) 
- [Data Flow of Requests](#data-flow-of-requests)

## Introduction 
The goal of this document is to describe the deployment structure  and deployment data flow of the SMS Checker app. The app is deployed in Kubernetes with Istio service mesh. Additionally, it implements a canary release to a small fraction of its users (90/10 traffic split) with Sticky Sessions and an additional use case, a Shadow Launch, which mirrors traffic to a new model version. An experiment is run to evaluate a canary release of the app to a small fraction of its users which enables caching model responses to improve latency. This document presents an overview of the deployment architecture, provides information on all deployed components and their relationships, a description of the request flow through the deployed cluster and a quick reference guide on how to access the application.

## Architecture Overview 
<!--Add a high level diagram of the architecture and a general description.-->
![High level diagram of application deployment](./images/highleveldiagram.png)
Figure 1: High level diagram of application deployment    

In Figure 1 the final architecture of the deployed application is depicted. The architecture leverages Kubernetes advanced deployment capabilities, monitoring and Istio for traffic management and continuous experimentation. All application components are deployed via a Helm chart and monitoring, including alerting, is enabled through Prometheus alongside Grafana for advanced dashboarding.

All external client traffic enters the cluster via an istio `Ingress Gateway` which is assumed to be available in the cluster. The app is installed in the cluster through its helm chart. The app defines an istio `Gateway` (my-gateway) resource which is linked to the istio `IngressGateway` by referring to the labels of the IngressGateway in the selector. The deployment uses the default label `istio: ingressgateway`. However, non-standard Istio installations may use different label names. The name of the `Gateway` is defined in the values of the helm chart but it can be overwritten to allow the deployment to be installed into different clusters that might use different names for the gateway. Moreover, the `Gateway` exposes the app under configurable hostnames and paths. These are defined and can be overwritten in the values of the helm chart. 

The current deployment uses the following hostnames and paths: 
<!--Add path /sms and metrics paths-->

| Hostname                 | Port | Path |  |
|--------------------------|------|------|---------|
| team8.local              | 8080   | /    | SMS Checker app |
| canary.team8.local       | 8080   | /    | Prereleased app (canary version) used for experimentation |
| prometheus.team8.local   | 8080   | /    | Prometheus web UI for metrics inspection and alerting|
| grafana.team8.local      | 8080   | /    | Grafana web UI for dashboarding 

An istio `VirtualService` (my-vs) is attached to the `Gateway` which is responsible for traffic routing to the SMS Checker app frontend, weighted traffic splitting (90/10) and Sticky Sessions. Sticky Sessions are implemented using a cookie (canary-user=true or canary-user=false), set by the frontend, such that the user selected for the canary version consistently sees the same version on subsequent requests. `DestinationRules` resources are responsible for defining subsets for the stable and canary releases and also for the Shadow Launch, enabling version-aware routing.

The app and its services (app-frontend, app-service, model) are deployed in multiple versions:
- A **Stable (v1)** deployment which serves most of the user (90%).
- A **Canary (v2)** deployment which serves a small fraction of the users (10%) and it is used for experimentation. This pre-release version of the `app-service` introduces a new feature in the app service. This new feature allows for caching model responses to improve latency.
- A **Shadow Launch (v3)** deployment introduces a new instance of the model service which mirrors existing traffic from v1 and v2 and runs a newer model version. The new model version is not exposed to the users and custom metrics are implemented in `model-service` to evaluate the new version.

`Virtual Services` app-service-vs and model-service-vs are implemented for ensuring that traffic is routed to the correct version (v1/v2) of the corresponding service.

An additional istio `VirtualService` (prometheus-vs) is attached to the `Gateway` and routes incoming traffic to the Prometheus instance, allowing access to its web UI (prometheus.team8.local). Prometheus is configured for app monitoring and alerting. The application exposes metrics which give insights into the usability of the app and the canary release, facilitating decision making on  the preferability of the new `app-service` version. These metrics are exposed by the `app-service` through an endpoint (\metrics). The metrics are automatically collected by Prometheus through a `ServiceMonitor` resource. Moreover, Prometheus `AlertManager` is configured with  a `PrometheusRule` for alerting users via email when the application receives more than 15 requests.

Similarly, an istio `VirtualService` (grafana-vs) is attached to the `Gateway` for routing traffic to the Grafana instance, allowing access to its UI (grafana.team8.local). Grafana is configured for visualizing the metrics. Two custom dashboards have been created that can be automatically added to Grafana during the app installation. One dashboard is for visualizing the general operation of the app and the other dashboard is used to illustrate the differences between the deployed versions in the experiment.

<!--More detailed info of the above will be provided below-->

## Deployment Structure
<!--Include all deployed resource types and their relations.
It is unnecessary to include all details for each CRD, but effects and relations should become clear. Mention about canary release(90/10) split, experiment (not in detail has each own doc), alerting, additional use case. Dont forget to mention here plain K8s deployment with Ingress (no Istio) Which component implements the additional use case?-->

![High level diagram of application deployment](./images/deployment_detailed.png)
Figure 2: Deployment Structure Diagram  

Figure 2 provides a detailed view of all deployed components and their connections. Details of all deployed resource types and their relations can be found below.

### Deployed Components

### Routing
---

### 1. Gateway (my-gateway) 
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### SMS Checker App
---
### 2. VirtualService (my-vs)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 3. DestinationRule (app-frontend-dr)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 4. Service (app-frontend)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 5. Deployment (app-frontend-v1)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 6. Deployment (app-frontend-v2)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 7. ConfigMap (frontend-v1-cookie-config)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 8. ConfigMap (frontend-v2-cookie-config)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 9. VirtualService (app-service-vs)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 10. DestinationRule (app-service-dr)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 11. Service (app-service)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 12. Deployment (app-service-v1)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 13. Deployment (app-service-v2)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 9. VirtualService (model-service-vs)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 10. DestinationRule (model-service-dr)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 11. Service (model-service)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 12. Deployment (model-service-v1)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 14. Deployment (model-service-v2)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 15. Deployment (model-service-v3)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

<!--Which component implements the additional use case?-->


### Grafana
---
### 16. VirtualService (grafana-vs)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 17. ConfigMap (grafana-dashboards-sms-app)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### Prometheus
---
### 18. VirtualService (premetheus-vs)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 19. ServiceMonitor (mymonitor)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 19. PrometheusRule (sms-app-alert)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 20. Alertmanager (email-alert)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 21. AlertmanagerConfig (email-config)
**Name:**  
**Type:**  
**Description:**  
**Connections:**

### 22. Secret (alertmanager-smtp-secret)
**Name:**  
**Type:**  
**Description:**  
**Connections:**






####



<!--
### Kubernetes:
#### Deployments
#### Services
#### Alerting
#### Ingress 

### Istio Service Mesh:

#### Traffic Management and Continuous Experimentation:
#### VirtualServices
#### Configmaps

#### Additional Use Case: Shadow Launch

#### App Monitoring
-->

## Data Flow of Requests
<!--Describe the flow of incoming requests to the cluster. Show and elaborate the flow of requests in the cluster, including the
dynamic traffic routing in your experiment. 
• Which path does a typical request take through your deployment?
• Where is the 90/10 split configured? Where is the routing decision taken?
Add data flow diagrams-->
