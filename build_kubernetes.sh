set -o errexit

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/kubernetes

echo "Building Kubernetes"

./build/run.sh make all
