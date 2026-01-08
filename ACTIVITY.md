### Week Q2.1 (10 Nov+)

No work done. 

### Week Q2.2 (17 Nov+)

- Vincent \
  https://github.com/doda2025-team8/model-service/pull/7 \
  https://github.com/doda2025-team8/app-service/pull/1 \
  https://github.com/doda2025-team8/app-frontend/pull/1 \
  I have worked on A1 and contributed a release workflow for Github Actions for the `model-service`, `app-serice`, and `app-frontend`.

- Andriana \
  https://github.com/doda2025-team8/operation/pull/1
  https://github.com/doda2025-team8/operation/pull/2  
  https://github.com/doda2025-team8/app-service/pull/7 
  https://github.com/doda2025-team8/app-frontend/pull/6    
  On A1 I worked on F7: Docker Compose Operation in ``operations`` repository. Moreover I set up a reversed proxy for app-frontend and app-service. Lastly, I worked on documentation.

- Yanzhi \
  https://github.com/doda2025-team8/model-service/pull/17 
  https://github.com/doda2025-team8/model-service/pull/15    
  A1: Implemented containerization with multi-stage, multi-architecture builds, added configurable port environment variables, created an automated training workflow, and built a dynamic model loader that downloads models from GitHub releases with caching.
  

- Hendrik \
  https://github.com/doda2025-team8/app-frontend/pull/2 
  https://github.com/doda2025-team8/app-service/pull/3 
  https://github.com/doda2025-team8/app-service/pull/8 
  https://github.com/doda2025-team8/model-service/pull/18

- Yuchen \
  https://github.com/doda2025-team8/lib-version/pull/3 
  https://github.com/doda2025-team8/model-service/pull/19
  https://github.com/doda2025-team8/app-service/pull/6     
  https://github.com/doda2025-team8/app-service/pull/5
  https://github.com/doda2025-team8/app-service/pull/4  
  A1:    
  F1 & F2: I developed the lib-version library to extract the single true version number directly from the pom.xml, and exposed it through the versionUtil class for consistent version retrieval.

  F11: I implemented automated version publishing for the app-frontend, app-service, and model-service repositories, enabling automatic promotion from pre-release to stable versions, GitHub publishing, and timestamp-based version tagging for commit traceability.

- Horia \
  https://github.com/doda2025-team8/model-service/pull/8 \
  Implemented initial containerization for `model-service` \
  Initialized set up and created rulesets to protect default branches \
  Reviewed PRs and provided feedback

### Week Q2.3 (24 Nov+)

- Vincent \ 
  https://github.com/doda2025-team8/operation/pull/11 \
  https://github.com/doda2025-team8/operation/pull/14 \ 
  I setup the steps 9 through 12 of the second assignment that covered the setting up of the Kubernetes repository, as well as installing the Kubernetes libraries, its dependencies and some extra libraries for future use. This is all done in the `operation` repository in the file `k8s/playbooks/general.yml`.
- Andriana \ 
  https://github.com/doda2025-team8/operation/pull/4
  For this week I worked on Step 1 and Step 2 concerning the setup of the VMs. I created a Vagrant file and set a host-only network. This is all done in the `operation` repository in the file `k8s/Vagrantfile`.  \
- Horia \
  https://github.com/doda2025-team8/operation/pull/13 \
  https://github.com/doda2025-team8/operation/pull/19 \
  For this week I worked on steps 3-8, concerning initial provisioning of the created VMs. I added the base steps for all VMs in the general playbook.
- Yanzhi \ 
  https://github.com/doda2025-team8/operation/pull/18
  For this week I worked on steps 18-19, on setting up the worker nodes. Wrote the Ansible playbook that joins worker nodes to the Kubernetes cluster by getting the join command from ctrl and running it on each worker.

- Hendrik\
  This week I worked on implementing step 13-17 (controller provisioning) \
  https://github.com/doda2025-team8/operation/pull/16

- Yuchen\
  For this week I worked on steps 20-22. I deployed MetalLB to provide bare-metal load balancing, the Nginx Ingress Controller to configure domain-based routing, and the K8s Dashboard to provide a convenient graphical interface for resource exploration. \
  https://github.com/doda2025-team8/operation/pull/20

### Week Q2.4 (1 Dec+)

- Hendrik\
  This week I worked on migrating the docker compose setup to kubernetes files, this can be seen in https://github.com/doda2025-team8/operation/pull/23 \
  Furthermore, I added health endpoints in the app-service and app-frontend\
  https://github.com/doda2025-team8/app-frontend/pull/7 \
  https://github.com/doda2025-team8/app-service/pull/11

- Vincent \
    https://github.com/doda2025-team8/operation/pull/24
    I setup the Helm Chart such that the app and its dependencies can be locally installed in a Kubernetes (e.g. minikube) install. I updated the README to also have the correct instructions for the installation of the app through Helm.

- Andriana \
    https://github.com/doda2025-team8/operation/pull/32
    I enabled monitoring though Prometheus by installing a Prometheus instance through Helm and introducing a ServiceMonitor to bind the app-service to this instance. Moreover, I enabled alerting. An email alert is sent when the service receives more than 15 requests per minute for two minutes straight.

- Yanzhi \
    https://github.com/doda2025-team8/operation/pull/33
    Created two Grafana dashboards: one for app metrics (request rate, active requests gauge, latency histogram) and one for A4 canary experiment comparison. Dashboards auto-install via ConfigMap and include multiple visualization types with PromQL functions like rate() and histogram_quantile().

- Yuchen Sun\
    [doda2025-team8/app-service#9](https://github.com/doda2025-team8/app-service/pull/9) For this week, I worked on Enable Monitroing. I successfully instrumented the app-service backend to produce custom business metrics (Counter, Gauge, and Histogram) and exposed them via the /actuator/prometheus endpoint, overcoming several local dependency and environment configuration issues.

- Horia \
    https://github.com/doda2025-team8/operation/pull/35
    For this week I implemented some (minor) fixes with the helm install. Updated documentation. Fixed an open item from last week.

### Week Q2.5 (8 Dec+)

- Yuchen \
    https://github.com/doda2025-team8/operation/pull/47
    Implement DestinationRules for 90/10 traffic split between old/new versions. Ensure consistent routing between app-service and model-service versions (old-old, new-new only). Implement Sticky Sessions for stable user routing. Test canary release with curl/Postman requests. Document routing behavior and testing approach

- Hendrik \
  On the app-servie I added caching of the model responses with prometheus metrics that get exported. It can be enabled with an environment variable.
  https://github.com/doda2025-team8/app-service/pull/12
  On the operations side, I fixed some issues with sticky sessions and implemented that the two app-service containers actually did something different. I also enabled added routes for grafana and prometheus and re-wrote parts of the documentation.
  https://github.com/doda2025-team8/operation/pull/48

- Yanzhi \
  Created the docs/continuous-experimentation.md documentation that describes the caching experiment (v1 no-cache vs v2 with-cache), including the hypothesis, metrics, and decision process.
  https://github.com/doda2025-team8/operation/pull/49
  Fixed the missing version labels in the app-service metrics by adding .tag("version", version) to all metrics in FrontendController.java and adding APP_VERSION environment variable to backend-deployment.yaml.
  https://github.com/doda2025-team8/app-service/pull/13
  Configured the Grafana dashboard, generated test traffic, and captured screenshots showing the experiment results.

- Vincent \
  https://github.com/doda2025-team8/operation/pull/40
  I setup Istio for the Helm app such that we can use it with a Gateway, VirtualService, and Destination Rule. I set it up to work with a tunnel, another team member will make it work with custom routing.

- Andriana \ 
  https://github.com/doda2025-team8/model-service/pull/23  
  https://github.com/doda2025-team8/operation/pull/50  
  This week I implemented an additional use case. The additional use is Shadow Launch. Additionally, I added some metrics with Prometheus in the model service to evaluate the new model version.

- Horia \ 
  https://github.com/doda2025-team8/operation/pull/52
  This week I analysed a short coming into the current release process and proposed an extension. The extension proposed is a vulnerability scanning for all docker images built, before pushing them to the registry, and also blocking kubernetes from running unscanned images.

### Week Q2.6 (15 Dec+)

-Yanzhi \
  https://github.com/doda2025-team8/model-service/pull/27
  https://github.com/doda2025-team8/operation/pull/68
  This week, focused on processing the feedbacks for A1 and A2, adjusted readme for model-service repository, fixed some vagrant setup for operation repository, removing unneccessary commands and optimize.
- Yuchen \
    https://github.com/doda2025-team8/lib-version/pull/6
    Fix problem in A1 Peer Review: F11 is implemented for lib-version repo now. The version is determined automatically. Used single source of truth for versioning for lib-version now. Also the pre-release for the branch commit also be added.

- Andriana \
  https://github.com/doda2025-team8/operation/pull/64
  https://github.com/doda2025-team8/operation/pull/63
  https://github.com/doda2025-team8/model-service/pull/25
  This week I worked on refining some parts of the project. Specifically, I updated alert manager to not contain sensitive information. The chart now provides an illustrative placeholder in values.yaml and allows for exchange during installation. Lastly, I fixed an error in model service that was causing the backend to crash due to wrong variable name reference.
- Vincwent \
  https://github.com/doda2025-team8/model-service/pull/26 \
  https://github.com/doda2025-team8/lib-version/pull/7 \ 
  https://github.com/doda2025-team8/app-service/pull/16 \
  This Week I processed some feedback from A1, wherein we should organise the repo a bit better such that it no longer needs the Maven wrappers etc. that were commited, those are not in the gitignore. Also I removed many redundant cmments as that was mentionted many times in all the feedback.

- Hendrik \
  https://github.com/doda2025-team8/app-service/pull/17\
  https://github.com/doda2025-team8/model-service/pull/28\
  This week I worked on feedback we received for A1. I tried to figure out a way to use the use the library without Github tokens, but that is not possible. The PR is still waiting for a merge in lib-version. I also worked on a small fix for the nodel-service release action.

- Horia
  https://github.com/doda2025-team8/operation/pull/69
  Worked on speeding up the vagrant provision. Also tried to automatically join nodes to the cluster but not successful.

  ### Week Q2.8 (5 Jan+)
- Yuchen
  