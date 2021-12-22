
install_package cfssl  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl version
install_package cfssljson  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson --version
install_package kubectl  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl "version --client"
# if ! command -v cfssl &> /dev/null
# then
#   wget -q --show-progress --https-only --timestamping \
#     https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl
  
#   sudo mv cfssl cfssljson /usr/local/bin/
#   chmod +x cfssl cfssljson
#   cfssljson --version
#   cfssl version
# else
#   print_comment "cfssl already exists"
# fi


#   https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson

# print_comment "install kubectl"
# wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
# chmod +x kubectl
# sudo mv kubectl /usr/local/bin/
# kubectl version --client