#update
sudo apt-get update -y

#install docker and golang, build kubernetes

set -o errexit

BASEDIR=$(dirname "${BASH_SOURCE}")
WIN_E2E_KUBE_BRANCH="win_e2e_testing"
KUBE_REPO="http://github.com/adelina-t/kubernetes"
GO_VERSION="1.10"

function program_is_installed() {
  local return_=1
  type $1 >/dev/null 2>&1 || { local return_=0; }
  echo "$return_"
}

function install_go() {
  if [ ! -d "/usr/lib/go-$GO_VERSION" ]; then
    echo "Installing golang"
    sudo add-apt-repository ppa:gophers/archive
    sudo apt-get update
    sudo apt-get install golang-$GO_VERSION-go -y
    mkdir $HOME/go $HOME/go/src $HOME/go/bin $HOME/go/pkg
    export GOROOT=/usr/lib/go-$GO_VERSION
    export GOBIN=$GOROOT/bin
    export GOPATH="$HOME/go"
    export PATH=$GOROOT/bin:$PATH:GOPATH/bin
  fi
}

function clone_k8s() {
  if [ ! -d "$BASEDIR/kubernetes" ]; then
    echo "Cloning Kubernetes repo $KUBE_REPO"
    git clone $KUBE_REPO
    cd $BASEDIR/kubernetes
    git checkout origin/$WIN_E2E_KUBE_BRANCH -b $WIN_E2E_KUBE_BRANCH
    cd ..
  fi
}

function install_docker(){
  if [[ $(program_is_installed docker) != "1" ]]; then
    echo "Installing docker"
    sudo apt-get install -y docker.io

    echo "Adding user $USER to docker group"
    sudo usermod -a -G docker $USER
  fi
}

function build_kubernetes() {
  KUBE_ROOT=$BASEDIR/kubernetes
  echo "Building Kubernetes"
  sudo $KUBE_ROOT/build/run.sh make all
}

install_go
install_docker
clone_k8s
build_kubernetes
