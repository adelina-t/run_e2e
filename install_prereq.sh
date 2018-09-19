#update
sudo apt-get update -y

#install docker and golang, build kubernetes

set -o errexit

GO_VERSION="1.10"

BASEDIR=$(dirname "${BASH_SOURCE}")
WIN_E2E_KUBE_BRANCH="win_e2e_testing"
KUBE_REPO="http://github.com/e2e-win/kubernetes"

echo "Installing docker"
sudo apt-get install -y docker.io

echo "Adding user $USER to docker group"
sudo usermod -a -G docker $USER


echo "Installing golang"
sudo add-apt-repository ppa:gophers/archive
sudo apt-get update
sudo apt-get install golang-$GO_VERSION-go

export GOROOT="/usr/lib/go-$GO_VERSION"
export PATH=$GOROOT/bin:$PATH

echo "Cloning Kubernetes repo $KUBE_REPO"

git clone $KUBE_REPO
cd $BASEDIR/kubernetes
git checkout origin/$WIN_E2E_KUBE_BRANCH -b win_e2e_testing



