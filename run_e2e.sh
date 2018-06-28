#check req env variables
if [ -z "$KUBE_MASTER_IP" ]; then echo "Need to set KUBE_MASTER_IP"; exit 1; fi
if [ -z "$KUBE_MASTER_URL" ]; then echo "Need to set KUBE_MASTER_URL"; exit 1; fi
if [ -z "$KUBECONFIG" ]; then echo "Need to set KUBECONFIG"; exit 1; fi
if [ -z "$KUBE_TEST_REPO_LIST" ]; then echo "Need to set KUBE_TEST_REPO_LIST"; exit 1; fi

if [ $# -lt 2 ]
then
  echo "Usage: $0 <is_dry_run> <focus_tests_file> [skip_tests_file]"
  exit 1
fi

if [ -z "$STY" ]
then
  exec screen -dm -S KUBE /bin/bash "$0" "$1" "$2"
fi

set -o errexit

DRY_RUN=$1
FOCUS=$2
SKIP=$3

GO_VERSION="1.10"
KUBETEST_URL=https://k8swin.blob.core.windows.net/k8s-windows/testing/kubetest/kubetest_2018-06-26-09-15-47/kubetest

function set_golang_env() {
  if [ -d "/usr/lib/go-$GO_VERSION" ]; then
    export GOROOT=/usr/lib/go-$GO_VERSION
    export GOPATH=$HOME/go
    export GOBIN=$GOROOT/bin
    export PATH=$GOROOT/bin:$PATH:GOPATH/bin
  else
    echo "Golang not installed. To install, run install_prereq.sh"
  fi
}

function get_kubetest() {
  echo "Downloading Kubetest"
  if [ -f $GOPATH/bin/kubetest ]; then
    rm $GOPATH/bin/kubetest
  fi
  wget $1 -O $GOPATH/bin/kubetest
  sudo chmod 755 $GOPATH/bin/kubetest
  touch $GOPATH/bin/kubetest
}

function get_tests_regex() {
  local tests_file=$1

  while IFS= read -r line
  do
    # skip comments in the file.
    if [ "$line" = "" ] || [ "#" = `echo $line | cut -b 1` ]
    then
      continue
    fi

    # Convert only space to dot
    line=`echo $line | sed "s/ /./g"`

    if [ "$TEXT" = "" ]
    then
      TEXT="$line"
    else
      TEXT="${line}|${TEXT}"
    fi
  done < "$tests_file"

  echo $TEXT
}

export GINKGO_NO_COLOR=y
export GINKGO_PARALLEL_NODES=12

FOCUS="`get_tests_regex $FOCUS`"
if [[ -n "$SKIP" ]]
then
  SKIP="`get_tests_regex $SKIP`"
fi

BASE_DIR=$(dirname "${BASH_SOURCE}")
KUBE_DIR=$BASE_DIR/kubernetes
E2E_RUN=hack/e2e.go
RESULTS_DIR=$BASE_DIR/results
mkdir -p $RESULTS_DIR

set_golang_env
get_kubetest $KUBETEST_URL

ginkgo_args="--num-nodes=2 --ginkgo.dryRun=${DRY_RUN:-false} "

if [[ -n "$FOCUS" ]]
then
  ginkgo_args+="--ginkgo.focus=${FOCUS} "
fi
if [[ -n "$SKIP" ]]
then
  ginkgo_args+="--ginkgo.skip=${SKIP} "
fi

e2e_args=("--")
e2e_args+=("--provider=local")
e2e_args+=("-v")
e2e_args+=("--test")
e2e_args+=(--test_args="$ginkgo_args")

cd $KUBE_DIR
go run $E2E_RUN "${e2e_args[@]}" | tee ../$RESULTS_DIR/acs_run_$(date +%Y_%m_%d_%H_%M)
