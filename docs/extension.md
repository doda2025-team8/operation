# Extension Proposal: Automated Image Scanning in CI/CD

One identified shortcoming of the release engineering process is the lack of security scanning of the images that are being pushed to the docker registry. Without image scanning it is hard to mitigate risks such as exposure to known vulnerabilities, increased attack surface due to misconfigured containers or delayed vulnerability detection which causes downtime and requires emergency patches.

## Extension Proposal

The proposal is to introduce a security gate in the CI/CD pipelines which build the images. This security gate scans the built images before they are pushed to the registry for the following:

1. Known Vulnerabilities and Exposures 
2. Outdated or vulnerable packages
3. Misconfigurations in container that could be exploited

The reports of these scans should be published at a known and reachable location such as the artifact repository. A good tool choice here is Trivy[https://github.com/aquasecurity/trivy], a popular security scanner.

## Implemenation plan

1. Pick some existing software which helps with vulnerability scanning. There are a lot of tools that can be used to scan docker images for vulnerabilities. It is recommended to make use of an external tool that is maintained and updated, instead of creating one. For this extension we propose to use Trivy which is nicely integrated with Githbu through Github actions. In other settings, more time should be spent 

2. Integrate into CI/CD: Currently, repositories model-service, app-frontend and app-service each have 2 Github workflows release.yml and prerelease.yml, which build and push containers to the Github Container registry. Both workflows need to be updated in each repository, so that they contain a step where the built docker images are scanned for vulnerabilities. The current setup uses an action that builds and pushes at the same step; to implement image scanning we need to split this process in 2 different jobs and add the scanning step(s) in between.

A possible code snippet for the scanning step is:

```
- name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'docker.io/my-organization/my-app:${{ github.sha }}'
          exit-code: '1'
          ignore-unfixed: true
          vuln-type: 'os,library'
          format: 'template'
          template: '@/contrib/sarif.tpl'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
```

Save image scan result:

```
- name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
```

If results are acceptable we create a signing + attestation mechanism. Attestation will be verified by pods before pulling the images.
## Success metrics

- all images are scanned before deployment
- reduction in vulnerabilities reaching prod

## Added value

The effect of this extension is a more secure release engineering process and an automation of scanning for vulnerabilities. Without an automation, it is very hard to mainatin an overview of the possibly compromised dependencies of a project.

## Other related work

This extension is a good step towards secure release engineering, however not sufficient on its own. It should be accompanied by other practicies such as pre-commit hooks, local code scanning, branching and release(change) policy. 