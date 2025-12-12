# Extension Proposal: Automated Image Scanning in CI/CD

One identified shortcoming of the release engineering process is the lack of security scanning of the images that are being pushed to the docker registry. Without image scanning it is hard to mitigate risks such as exposure to known vulnerabilities, increased attack surface due to misconfigured containers or delayed vulnerability detection which causes downtime and requires emergency patches.

## Extension Proposal

The proposal is to introduce a security gate in the CI/CD pipelines which build the images. This security gate scans the built images before they are pushed to the registry for the following:

1. Known Vulnerabilities and Exposuures 
2. Outdated or vulnerable packages
3. Misconfigurations in container that could be exploited

The reports of these scans should be published at a known and reachable location such as the artifact repository. A good tool choice here is Trivy[https://github.com/aquasecurity/trivy], a popular security scanner.

## Implemenation plan

1. Integrate into CI/CD: identifly pipelines which create docker images and introduce steps to set up Trivy and run the vulnerability scanner. Github has an action to achive this, find code snippets here[https://github.com/aquasecurity/trivy-action].

2. Define severity thersholds: define which vulnerabilities are high, critical, medium or just warnings. 

3. Use admission controllers in Kubernetes to prevent unscanned images: this can be implemented as an environment config, see https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/ 

4. Save scan results 

## Success metrics

- all images are scanned before deployment
- reduction in vulnerabilities reaching prod

## Added value

The effect of this extension is a more secure release engineering process and an automation of scanning for vulnerabilities. Without an automation, it is very hard to mainatin an overview of the possibly compromised dependencies of a project.

## Other related work

This extension is a good step towards secure release engineering, however not sufficient on its own. It should be accompanied by other practicies such as pre-commit hooks, local code scanning, branching and release(change) policy. 