set -o errexit

DRY_RUN=$1
FOCUS=$2

BASE_DIR=$(dirname "${BASH_SOURCE}")
KUBE_DIR=$BASE_DIR/kubernetes
E2E_RUN=$KUBEDIR/hack/e2e.go
RESULTS_DIR=$KUBEDIR/results
mkdir -p $RESULTS_DIR

ginkgo_args=("--ginkgo.dryRun=${DRY_RUN:-false}")
ginkgo_args+=("--ginkgo.focus=${FOCUS:-\[Conformance\]}")

e2e_args=("--")
e2e_args+=("--provider=local")
e2e_args+=("-v")
e2e_args+=("--test=")
e2e_args+=("--test_args='${ginkgo_args[@]}'")


cd $KUBE_DIR
go run $E2E_RUN ${e2e_args[@]} | tee $RESULTS_DIR/acs_run_$(date +%Y_%m_%d_%H_%M)
