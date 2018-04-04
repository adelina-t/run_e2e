#check req env variables
if [ -z "$KUBE_MASTER_IP" ]; then echo "Need to set KUBE_MASTER_IP"; exit 1; fi
if [ -z "$KUBE_MASTER_URL" ]; then echo "Need to set KUBE_MASTER_URL"; exit 1; fi
if [ -z "$KUBECONFIG" ]; then echo "Need to set KUBECONFIG"; exit 1; fi
if [ -z "$KUBE_TEST_REPO_LIST" ]; then echo "Need to set KUBE_TEST_REPO_LIST"; exit 1; fi

if [ $# -lt 2 ]
then
  echo "Usage: $0 <is_dry_run> <focus_tests_file>"
  exit 1
fi

if [ -z "$STY" ]
then
  exec screen -dm -S KUBE /bin/bash "$0" "$1" "$2"
fi

set -o errexit

DRY_RUN=$1
FOCUS=$2

while IFS= read -r line
do
  # skip comments in the file.
  if [ "$line" = "" ] || [ "#" = `echo $line | cut -b 1` ]
  then
    continue
  fi

  if [ "$TEXT" = "" ]
  then
    TEXT="$line"
  else
    TEXT="${line}|${TEXT}"
  fi
done < "$FOCUS"

FOCUS="$TEXT"

BASE_DIR=$(dirname "${BASH_SOURCE}")
KUBE_DIR=$BASE_DIR/kubernetes
E2E_RUN=hack/e2e.go
RESULTS_DIR=$BASE_DIR/results
mkdir -p $RESULTS_DIR

e2e_args=("--")
e2e_args+=("--provider=local")
e2e_args+=("-v")
e2e_args+=('--test_args="${ginkgo_args[@]}"')
e2e_args+=("--test")
if [[ -z "$FOCUS" ]]
then
  e2e_args+=(--test_args="--ginkgo.dryRun=${DRY_RUN:-false}")
else
  e2e_args+=(--test_args="--ginkgo.dryRun=${DRY_RUN:-false} --ginkgo.focus=${FOCUS}")
fi

cd $KUBE_DIR
go run $E2E_RUN "${e2e_args[@]}" | tee ../$RESULTS_DIR/acs_run_$(date +%Y_%m_%d_%H_%M)
