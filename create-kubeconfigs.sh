mkdir kubeconfigs
cd kubeconfigs

print_headline "generate kubeconfig files"

print_comment "retrieve external IP"
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')


print_comment "generate kublets kubeconfig files"
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=../certs/${instance}.pem \
    --client-key=../certs/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done


print_comment "generate kube proxy kubeconfig files"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=../certs/kube-proxy.pem \
    --client-key=../certs/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

print_comment "generate controller manager kubeconfig file"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=../certs/kube-controller-manager.pem \
    --client-key=../certs/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}

print_comment "generate kube scheduler kubeconfig file"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=../certs/kube-scheduler.pem \
    --client-key=../certs/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}

print_comment "generate admin kubeconfig file"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=../certs/admin.pem \
    --client-key=../certs/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}

print_comment "copy kubelet & kube proxy kubeconfig files to worker nodes"

for instance in worker-0 worker-1 worker-2; do
  gcloud -q compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done


print_comment "copy kube scheduler & controller manager kubeconfig files to controlplane nodes"
for instance in controller-0 controller-1 controller-2; do
  gcloud -q compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done

cd ..
