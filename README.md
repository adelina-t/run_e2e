# run_e2e_remotely

Small collection of scripts to build and run Kubernetes e2e tests on a remote cluster

## Usage

### Install prerequsites: Docker, golang. Clone Kubernetes Repo.

```
./install_prereq.sh
```

NOTE: User is added to the docker group. Logout and login again for changes to be in effect.

### Build kubernetes components

```
./build_kubernetes.sh
```

### Run tests

Before running the tests, edit the kube_env file with the appropriate env variables for the deployment and source.
```
source kube_env
```

Run tests:
```
./run_e2e.sh
```
By default all conformance tests are ran.
You can do a dry run with:
```
./run_e2e.sh true
```

All results are placed in .results

