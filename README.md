![Actions Status](https://github.com/machine-learning-apps/gke-kubeconfig/workflows/Build/badge.svg)

## This Action retrieves a [kubeconfig file](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) from [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/)

### This action saves the kubeconfig file into the following directory:

`$GITHUB_WORKSPACE/.kube/config`

- Inside a Docker container running in Actions, $GITHUB_WORKSPACE is mounted such that this directory always equals `/github/workspace`. **Therefore, the kubeconfig file in a subsequent action running in a Docker container can be found at `/github/workspace/.kube/config`**

- Note that outside a Docker container $GITHUB_WORKSPACE is not `/github/workspace` (you must reference the environment variable to see the directory). 

The purpose of this action is to retrieve a kubeconfig file so that other actions can use `kubectl` to interact with your GKE cluster.  An overview of how to retrieve this config file manually are located in [these docs](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)


## Notes on the kubeconfig file:

From [this explanation](https://ahmet.im/blog/mastering-kubeconfig/):

If you’re using `kubectl`, here’s the preference that takes effect while determining which kubeconfig file is used.

1. use `--kubeconfig` flag, if specified
2. use `KUBECONFIG` environment variable, if specified
3. use `$HOME/.kube/config file`


## Usage

### Example Workflow That Uses This Action

This action is the third step in the below example: `Submit Argo Deployment`

```yaml
name: Test GKE kubeconfig
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # this action will save the kubeconfig file to `/github/workspace/.kube/config`, which is visible to subsequent steps.
    - name: Get kubeconfig file from GKE
      uses: machine-learning-apps/gke-kubeconfig@master
      with:
        application_credentials: ${{ secrets.APPLICATION_CREDENTIALS }}
        project_id: ${{ secrets.PROJECT_ID }}
        location_zone: ${{ secrets.LOCATION_ZONE }}
        cluster_name: ${{ secrets.CLUSTER_NAME }}
        
    - name: Test Kubeconfig File
      uses: docker://bitnami/kubectl:latest
      with:
        args: get namespaces
      env:
        # Setting the environment variable KUBECONFIG sets the default config file that kubectl looks for.
        KUBECONFIG: '/github/workspace/.kube/config'
```

### Mandatory Arguments

1. `APPLICATION_CREDENTIALS`: base64 encoded GCP application credentials (https://cloud.google.com/sdk/docs/authorizing).  To base64 encode your credentails, you can run this command:

    > cat your-gke-credentials.json | base64

2. `PROJECT_ID`: Name of the GCP Project where the GKE K8s cluster resides.
3. `LOCATION_ZONE`: The location-zone where your GKE K8s cluster resides, for example, `us-west1-a`
4. `CLUSTER_NAME`: The name of your GKE K8s cluster.

## Keywords
 MLOps, Machine Learning, Data Science
