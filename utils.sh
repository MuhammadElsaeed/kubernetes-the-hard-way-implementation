function print_headline(){
    tput setaf 4 && tput bold && echo -e "\n==> $1 <==" && tput sgr0;
}

function print_comment(){
    tput setaf 3 && echo -e "$1" && tput sgr0;
}



function install_package(){
    package_name=$1
    package_url=$2
    package_version_parameter=$3

    print_headline "install ${package_name}"
    if ! command -v $package_name &> /dev/null
    then
        wget -q --show-progress --https-only --timestamping \
            $package_url
        chmod +x $package_name
        sudo mv $package_name /usr/local/bin/
        $package_name $package_version_parameter
    else
        print_comment "${package_name} already exists"
    fi
}
