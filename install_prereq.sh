#!/bin/bash
# This script is used to install docker golang and build kubernetes

set -e -o pipefail

BASEDIR=$(dirname "${BASH_SOURCE}")
WIN_E2E_KUBE_BRANCH="win_e2e_testing"
KUBE_REPO="http://github.com/adelina-t/kubernetes"
GO_VERSION="1.10"

sudo apt-get update -y

function program_is_installed() {
  local return_=1
  type $1 >/dev/null 2>&1 || { local return_=0; }
  echo "$return_"
}

function install_go() {
  echo "Installing golang"

  DEBIAN_FRONTEND=noninteractive sudo apt-get install golang-$GO_VERSION-go -y
  mkdir -p $HOME/go/{bin,pkg,src}

  echo "Make sure you properly set the following env variables"
  echo "GO_VERSION=$GO_VERSION"
  echo 'export GOROOT=/usr/lib/go-$GO_VERSION'
  echo 'export GOBIN=$GOROOT/bin'
  echo 'export GOPATH="$HOME/go"'
  echo 'export PATH=$GOROOT/bin:$PATH:$GOPATH/bin'
}

function install_docker(){
  if [[ $(program_is_installed docker) != "1" ]]; then
    echo "Installing docker"
    DEBIAN_FRONTEND=noninteractive sudo apt-get install docker.io -y

    echo "Adding user $USER to docker group"
    sudo usermod -a -G docker $USER
  fi
}

function clone_k8s() {
  if [ ! -d "$BASEDIR/kubernetes" ]; then
    echo "Cloning Kubernetes repo $KUBE_REPO"
    git clone $KUBE_REPO
    pushd $BASEDIR/kubernetes
    	git checkout origin/$WIN_E2E_KUBE_BRANCH -b $WIN_E2E_KUBE_BRANCH
    popd
  fi
}

install_go
install_docker
clone_k8s

newgrp docker
