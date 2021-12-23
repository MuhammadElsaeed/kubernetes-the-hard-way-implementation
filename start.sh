source utils.sh
source install-packages.sh
source provision-resources.sh
source create-certs.sh
source create-kubeconfigs.sh
source create-encryption-keys.sh

print_headline "bootstrap etcd server on each controlplane node"

for instance in controller-0 controller-1 controller-2; do
  print_comment "install etcd on ${instance}"
  gcloud compute scp remote-scripts/bootstrap-etcd.sh ${instance}:/tmp/
  gcloud compute ssh ${instance} --command "sudo chmod +x /tmp/bootstrap-etcd.sh"
  gcloud compute ssh ${instance} --command  "sudo /tmp/bootstrap-etcd.sh"
done

print_comment "list the etcd cluster members"
gcloud compute ssh controller-0 --command "sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem"

print_headline "bootstrap kubernetes controllers"
for instance in controller-0 controller-1 controller-2; do
  print_comment "configure kubernetes conrollers on ${instance}"
  gcloud compute scp remote-scripts/bootstrap-controllers.sh ${instance}:/tmp/
  gcloud compute ssh ${instance} --command "sudo chmod +x /tmp/bootstrap-controllers.sh"
  gcloud compute ssh ${instance} --command  "sudo /tmp/bootstrap-controllers.sh"
done

print_comment "RBAC for Kubelet Authorization"
  gcloud compute scp remote-scripts/RBAC-for-kubelet.sh  controller-0:/tmp/
  gcloud compute ssh  controller-0 --command "sudo chmod +x /tmp/RBAC-for-kubelet.sh"
  gcloud compute ssh  controller-0 --command  "sudo /tmp/RBAC-for-kubelet.sh"


print_headline "provision load balancer"
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

gcloud compute http-health-checks create kubernetes \
  --description "Kubernetes Health Check" \
  --host "kubernetes.default.svc.cluster.local" \
  --request-path "/healthz"

gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
  --network kubernetes-the-hard-way \
  --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
  --allow tcp

gcloud compute target-pools create kubernetes-target-pool \
  --http-health-check kubernetes

gcloud compute target-pools add-instances kubernetes-target-pool \
  --instances controller-0,controller-1,controller-2

gcloud compute forwarding-rules create kubernetes-forwarding-rule \
  --address ${KUBERNETES_PUBLIC_ADDRESS} \
  --ports 6443 \
  --region $(gcloud config get-value compute/region) \
  --target-pool kubernetes-target-pool

print_comment "verification"
curl --cacert certs/ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
