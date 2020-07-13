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

function get_tests_regex() {
  local tests_file=$1

  while IFS= read -r line
  do
    # skip comments in the file.
    if [ "$line" = "" ] || [ "#" = `echo $line | cut -b 1` ]
    then
      continue
    fi

    # Convert non-alphabetic characters to dot
    line=`echo "$line" | sed "s/\W/./g"`

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
export GINKGO_PARALLEL=n
export GINKGO_DRYRUN=${DRY_RUN:-false}
export DOCKER_CONFIG_FILE="/home/ubuntu/.docker/config.json"
export KUBECTL=`which kubectl`
export KUBERNETES_CONFORMANCE_TEST=yes
export NUM_NODES=2
export NODE_OS_DISTRO="windows"

if [[ -n "$FOCUS" ]]
then
  export CONFORMANCE_TEST_FOCUS_REGEX="`get_tests_regex $FOCUS`"
fi
if [[ -n "$SKIP" ]]
then
  export CONFORMANCE_TEST_SKIP_REGEX="`get_tests_regex $SKIP`"
fi

BASE_DIR=$(dirname "${BASH_SOURCE}")
KUBE_DIR=$BASE_DIR/kubernetes
E2E_RUN=hack/ginkgo-e2e.sh
RESULTS_DIR=$BASE_DIR/results
mkdir -p $RESULTS_DIR

cd $KUBE_DIR

${E2E_RUN} | tee ../$RESULTS_DIR/acs_run_$(date +%Y_%m_%d_%H_%M)
