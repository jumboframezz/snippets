#!/bin/bash 

# shellcheck disable=1091
[ -f /etc/os-release ] && . /etc/os-release
# repo_url="http://repos.office.corp/repository/gitlab"
repo_url="http://nexus.lz1lgg.eu/repository/gitlab"

rocky_repo(){
cat > "$1" <<EOF
[gitlab_gitlab-ce]
name=gitlab_gitlab-ce
baseurl=$repo_url/gitlab-ce/el/$releasever/$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
gpgkey=$repo_url/gitlab-ce/gpgkey
       $repo_url/gitlab-ce/gpgkey/gitlab-gitlab-ce-3D645A26AB9FBD22.pub.gpg
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

# [gitlab_gitlab-ce-source]
# name=gitlab_gitlab-ce-source
# baseurl=https://packages.gitlab.com/gitlab/gitlab-ce/el/7/SRPMS
# repo_gpgcheck=1
# gpgcheck=1
# enabled=1
# gpgkey=https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey
#        https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey/gitlab-gitlab-ce-3D645A26AB9FBD22.pub.gpg
# sslverify=1
# sslcacert=/etc/pki/tls/certs/ca-bundle.crt
# metadata_expire=300

EOF
}


case "$ID" in

    rocky)
        repo_file="/etc/yum.repos.d/gitlab_gitlab-ce.repo"
        rocky_repo $repo_file
        ;;
    debian)
        apt-get install -y gnupg curl debian-archive-keyring  apt-transport-https
        repo_file="/etc/apt/sources.list.d/gitlab_gitlab-ce.list"
        gpg_key_url="https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey"
        # gpg_keyring_path="/usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg"
        gpg_trusted_path="/etc/apt/trusted.gpg.d/gitlab_gitlab-ce.gpg"
        curl -fsSL "${gpg_key_url}" | gpg --dearmor > ${gpg_trusted_path}
        echo "deb [signed-by=$gpg_trusted_path] $repo_url/gitlab-ce/debian/ bookworm main" > $repo_file
        apt update
        apt-cache policy gitlab-ce
        ;;

    *)
        echo "Unknown distro"
        exit 130
        ;;
esac