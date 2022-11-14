# PodChaosMonkey

## Set up Minikube
To set up a local cluster with minikube, follow [instructions](https://minikube.sigs.k8s.io/docs/start/).

## Build PodChaosMonkey Docker image

To build the image locally, run:

```
$ docker build -t chaos:v1 .
```
## Run Dummy workload inside local cluster:

To apply the k8s manifests for dummy workload:

```
$ kubectl apply -f manifests/dummy/.
```

## Run PodChaosMonkey inside local cluster:

To apply the k8s manifests for PodChaosMonkey:
```
$ kubectl apply -f manifests/podchaosmonkey/.
```

## Overview

Spinnaker is an open source, multi-cloud continuous deployment tool. It will be used to deploy infrastructure for Eagle Eye's AIR platform.

The base infrastructure as well as a private GitHub Action runner is deployed in **mgcp-1068761-control-plane** project.

## Architecture

Spinnaker OSS has been deployed as a distributed installation in GKE Autopilot. The installation deploys a bunch of microservices where each performs a specific role. Find out more about each of the microservice [here](https://spinnaker.io/docs/reference/architecture/microservices-overview/).

These microservices can be customized and fine-tuned further to increase performance. Below is the architecture diagram for Spinnaker:

![](./spinnaker-architecture.png)


## Installation, Configuration and Customization
Halyard is used to configure, install and update Spinnaker. Halyard has three parts, the halconfig, the daemon and hal. The hal CLI send commands to the hal daemon which then updates the halconfig file located in .hal/config. The halconfig is source of all configuration for the Spinnaker deployment. 

Further customization to the Spinnaker deployment can be done with halyard's custom profile and service settings. For example, by default each microservice is deployed with the default k8s service account. Through service-settings, the identity the microservices uses has been changed to a non default service account *(spinnaker-prod-sva)*. More info on custom settings can be found [here](https://spinnaker.io/docs/reference/halyard/custom/).


GitHub Action pipelines and hal CLI have been used to automate the Spinnaker deployment.

## Spinnaker secrets
Secrets can be referenced in the halconfig and profiles using Spinnaker's end-to-end secrets management. It uses GCS to store the secrets, therefore it is very important to disable public access to the bucket (**spinnaker-prod-assets**). Reference the secret literal values using the syntax described [here](https://spinnaker.io/docs/reference/halyard/secrets/). There are several secrets that have been referenced in the halfconfig using this system.

### Ingress and Cloud IAP
Spinnaker provides two endpoints to connect - Deck and API Gateway. Deck service is the Spinnaker UI and has been exposed with a k8s ingress which creates a L4 TCP Loadbalancer. Cloud IAP has been configured on spin-deck service in the backend to add authorization layer before requests are forwarded to the Deck UI. The Deck service has a **/gate** internal proxy which it uses to access and make calls to the API Gateway. 

Authentication has been enforced using Spinnaker's native intergration with Cloud IAP.
```
$ hal config security authn iap edit --audience /projects/PROJECT_NUMBER/global/backendServices/SERVICE_ID
```
```
$ hal config security authn iap enable
```

Managed SSL has been provisioned through a k8s resource for domain - https://spinnaker.infrastructure.eagleeye.network/. To connect to Spinnaker UI, users need to have a valid google account with **IAP-Secured Web App User** IAM role.

### External Secrets
External secrets is an open source k8s operator that integrates with GCP Secret Manager to sync secrets into the GKE Autopilot cluster. It currently syncs the Terraform Cloud API token and GitHub PAT which is used for terraform pipelines inside Spinnaker. The operator was installed in the cluster with helm:
```
$ helm install external-secrets external-secrets/external-secrets --namespace=es
```

More info can be found [here](https://external-secrets.io).

## Usage
Spinnaker configuration changes should be driven through the GitHub Actions pipelines - halyard plan and halyard apply.
Terraform configuration changes for the GH actions runner and Spinnaker infra is done with ```infra-air-spinnaker-prod``` workspace in Terraform Cloud.   
### GitHub Action Runner
A Compute Engine VM has been deployed to act as a private runner to run GitHub Action jobs for the *infrastructure-spinnaker* repository. The runner is set up using a startup script which downloads a GitHub PAT *(spinnaker_git-pat_token)* from GCP Secret Manager and uses it to register itself as a runner for the repo. The terraform configuration files is located in REPO/terraform/production.

To remove the runner, SSH into the runner VM and run the shutdown.sh script:
```
$ sudo runner-tmp/runner-tmp/infrastructure-spinnaker/terraform/actionsprivaterunner/scripts/shutdown.sh
```

### Spinnaker Config Pipeline
To change Spinnaker's configuration, two pipelines have been set up - ```halyard plan``` and ```halyard apply```. Both of the pipelines is configured to be manually triggered.

#### halyard plan
This pipeline prepares and validates new Spinnaker configs. These configs changes are driven with halconfig file, service-settings and hal CLI.
1. Navigate to halyard plan workflow in Actions page.
1. Click on run workflow and select the branch you want the workflow to run from.
1. Enter if any, hal CLI command to prepare the halconfig. If left blank, the pipeline only uses files from .hal directory to make config changes.
1. View the workflow steps for a successful run.
1. If successful, the new config file is saved to a ```/tmp_dir``` on the private runner.

#### halyard apply
1. Navigate to halyard apply workflow in Actions page.
1. Ensure you run halyard plan workflow to avoid any stale plan.
1. Click on run workflow and select the branch you want the workflow to run from.
1. Select what you want to run. There are a few options:
    - Apply halconfig: applies the halconfig saved in the ```/tmp_dir``` from the halyard plan pipeline.
    - Update Spinnaker Ingress: applies manifest files in ```infrastructure-spinnaker/manifests/spinnaker-infra```.
1. If changes to halconfig file is performed with hal CLI during halyard plan, they will be auto-commited to the branch to reconcile the changes in git. 

### Terraform Pipeline
There are two terraform pipelines defined within Spinnaker to deploy AIR plaform's infrastructure.
#### terraform-hotfix
This pipeline is intended to apply a hotfix to any of the infrastructure-air environments.
1. Select the tag you want to checkout.
1. Check the plan and validate the deployment is as you expect.
1. Approve the plan.
1. Applies the Terraform plan.
1. Updates the project metadata to the deployed git version.

#### terraform-env-promotion
This pipeline is intended to test new infra deployments in dev-us first, and then gradually promote the change to different environments. 
1. Select the tag you want to checkout.
1. Check the dev-us plan and validate the deployment is as you expect.
1. Approve the plan.
1. Applies the Terraform plan.
1. Updates the project metadata to the deployed git version.
1. Performs plan on alpha-us.
1. Repeat step 3-5 to promote the change to different environments.

## Further Reading

### Productionize Spinnaker and HA configuration
Beyond horizontally scaling services, halyard can be used to increase availability of specific service by splitting the functionalities of a service into logical roles. Spinnaker documentation provides two methods of achieving this:

More info on HA config can be found [here](https://spinnaker.io/docs/reference/halyard/high-availability/).

More info on Productionize Spinnaker can be found [here](https://spinnaker.io/docs/setup/productionize/).