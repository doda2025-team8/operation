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

- Hendrik \
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

- Yanzhi \
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

- Vincent \
  https://github.com/doda2025-team8/model-service/pull/26 \
  https://github.com/doda2025-team8/lib-version/pull/7 \
  https://github.com/doda2025-team8/app-service/pull/16 \
  This Week I processed some feedback from A1, wherein we should organise the repo a bit better such that it no longer needs the Maven wrappers etc. that were commited, those are not in the gitignore. Also I removed many redundant cmments as that was mentionted many times in all the feedback.

- Hendrik  
  https://github.com/doda2025-team8/app-service/pull/17  
  https://github.com/doda2025-team8/model-service/pull/28  
  This week I worked on feedback we received for A1. I tried to figure out a way to use the use the library without Github tokens, but that is not possible. The PR is still waiting for a merge in lib-version. I also worked on a small fix for the nodel-service release action.

- Horia  
  https://github.com/doda2025-team8/operation/pull/69 \
  Worked on speeding up the vagrant provision. Also tried to automatically join nodes to the cluster but not successful.

### Week Q2.7 (Jan 5+)

- Vincent \
  https://github.com/doda2025-team8/operation/pull/81 \ 
  This week I process some feedback from A2 and on and we had a meeting on how to split the work on processing the feedback with the view of the final submission approaching. I split some templates into seperate files, as that was pointed to in the feedback and redid the structure of the README such that it is a bit simpler to use.

- Andriana   
  https://github.com/doda2025-team8/operation/pull/83
  https://github.com/doda2025-team8/operation/pull/84
  This week I worked on feedback from A1, I updated the envs used in the docker compose as well as the readme. I also worked on the deployment documentation. Lastly, I attended the meeting we had on processing the feedback from a4.

- Yanzhi  
  https://github.com/doda2025-team8/app-service/pull/19
  This week I worked on feedback from A3, I fixed the no Histogram and the metrics are not broken down with labels issue for app monitoring in the app-service.

- Yuchen  
  https://github.com/doda2025-team8/operation/pull/79
  Added Assignment2 step23 -- Install Istio. The Istio Pods are running, and a fixed IP has assigned to the Istio: istio-ingressgateway   LoadBalancer ... 192.168.56.92

- Hendrik  
  https://github.com/doda2025-team8/model-service/pull/29
  Fixed CI pipeline build authentication
  
### Week Q2.8 (Jan 12+)

- Andriana  
  https://github.com/doda2025-team8/operation/pull/90
  https://github.com/doda2025-team8/operation/pull/89  
  This week I worked on implementing feedback from A2 regarding the provisioning of the cluster. Moreover, I created a high level diagram of our system deployment to add to the documentation. 

- Yanzhi  
  https://github.com/doda2025-team8/operation/pull/88
  This week I worker on fixing the feedback from A4 continuous experimentation, added configurable canaryHostname, canary-vs VirtualService and updated continuous-experimentation.md with experiment design and config references.

- Vincent \
  https://github.com/doda2025-team8/operation/pull/94 \
  Autogenerate the inventory files such that a differnet number of worker nodes is supported in the Ansible playobok

- Hendrik  
  https://github.com/doda2025-team8/operation/pull/91  
  https://github.com/doda2025-team8/operation/pull/92  
  https://github.com/doda2025-team8/app-frontend/pull/11  
  https://github.com/doda2025-team8/app-service/pull/23  
  This week I made the Istio sessions sticky by letting the frontend set the canary cookie. Istio itself cannot set the cookie correctly, but the frontend is the first point that is hit by a new client, so this works. I also moved the moved the experiment into its own branch and performed some bug fixes in general and wrote some documentation.

- Yuchen  
  https://github.com/doda2025-team8/app-frontend/pull/10
  http://github.com/doda2025-team8/app-service/pull/22
  This week I removed all metric endpoints which was based on the Micrometer Lib. I rewrote these endpoints with the same function. And I aslo added one UI-related metric endpoint. It tracks the changes from the frontend of the app.

### Week Q2.9 (Jan 19+)

- Yanzhi 
  https://github.com/doda2025-team8/operation/pull/104
  This week I worked on finalizing and refactoring readme files based on the feedbacks we received.

- Hendrik  
  This week I worked on a lot of small issues we had. This first PR sets specific image versions for the helm chart and docker-compose configurations. https://github.com/doda2025-team8/operation/pull/108  
  This second PR is to speed up vagrant provisioning by running the ansible playbooks in parallel.https://github.com/doda2025-team8/operation/pull/109  
  The following PR sets the grafana and prometheus stack as a helm dependency, allowing for automatic installation. It also addresses some erros in the experimentation guide and readme. https://github.com/doda2025-team8/operation/pull/107  
  Lastly, a shared folder was implemented to support serving additional files with app-frontend.
  https://github.com/doda2025-team8/operation/pull/111

- Andriana   
  https://github.com/doda2025-team8/operation/pull/96      
  This week I continued working on the deployment documentation. I created a detailed diagram of the deployment,depicting all the deployed resources and added descriptions for each resource. Moreover, I spent time reviewing PRs.

- Yuchen    
  https://github.com/doda2025-team8/app-service/pull/24    
  I updated the README file of the app-service in this PR.
  https://github.com/doda2025-team8/operation/pull/100     
  I add a requirement in A2: Provide SSL/TLS keys to the dashboard in this PR.  
  https://github.com/doda2025-team8/operation/pull/105    
  I change it to the correct prometheus metric path in this PR.
