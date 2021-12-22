source utils.sh
source install-packages.sh

print_headline "set GCP default region &zone"
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c