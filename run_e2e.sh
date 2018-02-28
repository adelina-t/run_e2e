if [ -z "$STY" ]
then
  exec screen -dm -S KUBE /bin/bash "$0"
fi

set -o errexit

DRY_RUN=$1
FOCUS=$2

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
