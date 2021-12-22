package_name=$1
package_url=$2
package_version_parameter=$4


if ! command -v $($package_name) &> /dev/null
then
  wget -q --show-progress --https-only --timestamping \
    $package_url
  
  sudo mv $package_name /usr/local/bin/
  chmod +x $package_name
  $($package_name $package_version_parameter)
else
  print_comment "${package_name} already exists"
fi
