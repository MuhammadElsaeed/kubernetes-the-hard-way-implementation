print_headline "set GCP default region &zone"
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c

print_headline "setup networking"

print_comment "create VPC"
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom

print_comment "create subnet"
gcloud compute networks subnets create kubernetes \
  --network kubernetes-the-hard-way \
  --range 10.240.0.0/24

print_comment "setup firewall rules"
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  --allow tcp,udp,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 10.240.0.0/24,10.200.0.0/16

  gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 0.0.0.0/0

gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"

print_comment "create static IP for the internet facing load balancer"
gcloud compute addresses create kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region)
gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"

print_headline "provision 3 controlplane vm instances"
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-2 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,controller
done


print_headline "provision 3 worker nodes vm instances"

for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-2 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
done

IP=$(gcloud compute instances list | awk '/'worker-2'/ {print $5}')
while !(nc -w 3 -z $IP 22); do
    echo "instances are not ready yet."
done
sleep 10

gcloud compute instances list --filter="tags.items=kubernetes-the-hard-way"
