source utils.sh
source install-packages.sh
source provision-resources.sh
source create-certs.sh
source create-kubeconfigs.sh
source create-encryption-keys.sh

print_headline "bootstrap etcd server on each controlplane node"

for instance in controller-0 controller-1 controller-2; do
  print_comment "install etcd on ${instance}"
  gcloud compute scp bootstrap-etcd.sh ${instance}:/tmp/
  gcloud compute ssh ${instance} --command "sudo chmod +x /tmp/bootstrap-etcd.sh"
  gcloud compute ssh ${instance} --command  "sudo /tmp/bootstrap-etcd.sh"
done

print_comment "list the etcd cluster members"
gcloud compute ssh controller-0 --command "sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem"
