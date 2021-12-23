# Kubernetes the hard way implementation
This is practical implementation of [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) with bash scripts.
The kubernetes version used is v1.21.0.
## Prerequisites
Because the cluster will be provisioned on GCP, you need Google Cloud SDK installed on your machine and configured with your account:
```
gcloud auth login
```

And also make sure to set the project:
```
gcloud config set project <project-id>
```

## Provision the cluster
All you need to do is to run the start script:

```
./start.sh
```

The proccess takes about 20 minutes to compelete and you will have a a working kubernetes cluster (3 controlplane nodes, 3 worker nodes) up and runnung.

Your kubeconfig will be configured to use the cluster and you can switch to the cluster context when you need:
```
kubectl config use-context kubernetes-the-hard-way
```

Test if the cluster is working:
```
kubectl get nodes
```
You should get the following output:
```
NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   96s   v1.21.0
worker-1   Ready    <none>   64s   v1.21.0
worker-2   Ready    <none>   29s   v1.21.0
```

## Destroy the cluster
When you are done you can destroy the cluster by running the destroy script:
```
./destroy.sh
```
