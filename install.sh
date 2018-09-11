# https://rancher.com/docs/rke/v0.1.x/en/installation/
set -e

RANCHER_VERSION=0.1.9
K8S_VERSION=1.11.2

BINARY_FOLDER=bin

if [ -f "${BINARY_FOLDER}/.ok" ]; then
    echo "Tools OK !"
else
    mkdir -p ${BINARY_FOLDER}
    pushd ${BINARY_FOLDER}
    if [ "$(uname -s)" == "Darwin" ]; then
        echo "Downloading RKE (mac version)..."
        curl -o rke -L https://github.com/rancher/rke/releases/download/v${RANCHER_VERSION}/rke_darwin-amd64
        echo "Downloading kubectl..."
        curl -LO https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/darwin/amd64/kubectl
        # echo "Downloading kubefed..." # Note : skipping kubefed, as federation API v1 is beta, and won't GA. Federation V2 API is WIP.
        # curl -o federation-client-amd64.tar.gz -L https://storage.cloud.google.com/kubernetes-federation-release/release/${K8S_VERSION}/federation-client-darwin-amd64.tar.gz
        # tar xzvf federation-client-amd64.tar.gz
    else
        echo "Downloading RKE (linux version)..."
        curl -o rke https://github.com/rancher/rke/releases/download/v${RANCHER_VERSION}/rke_linux-amd64
        echo "Downloading kubectl..."
        curl -LO https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl
        # echo "Downloading kubefed..." # Note : skipping kubefed, as federation API v1 is beta, and won't GA. Federation V2 API is WIP.
        # curl -o federation-client-amd64.tar.gz -L https://storage.cloud.google.com/kubernetes-federation-release/release/${K8S_VERSION}/federation-client-linux-amd64.tar.gz
        # tar xzvf federation-client-amd64.tar.gz
    fi
    touch .ok
    popd
fi
# Getting permissions right
chmod u+x "${BINARY_FOLDER}/rke"
chmod u+x "${BINARY_FOLDER}/kubectl"

if [ -z "$(vagrant plugin list | grep vagrant-hostmanager)" ]; then
    # Adding needed vagrant plugins
    vagrant plugin install vagrant-hostmanager # Manage host resolution for VMs
fi

echo "Setting PATH to include tools..."
export PATH="$PWD/${BINARY_FOLDER}:$PATH" # FIXME : don't add if already in $PATH 

echo "Creating infrastructure..."
vagrant up

echo "Installing kubernetes cluster..."
#rke up
rke --debug up

#alias kubectl-rke='kubectl --kubeconfig kube_config_cluster.yml'
echo "Setting configuration as default one for kubectl (to redo : export KUBECONFIG=kube_config_cluster.yml)..."
export KUBECONFIG=kube_config_cluster.yml

echo "Checking installation :"
kubectl version
kubectl cluster-info | grep -v dump
echo "Checking pods state :"
kubectl get pods -o wide  --all-namespaces

echo "Installation Done."

# Then, to connect to the dashboard :
echo "Launching proxy for dashboard : kubectl proxy"
echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
echo "Once there, login with the following token :"
TOKEN_NAME=$(kubectl -n kube-system  get secret | grep admin-user | awk '{print $1}')
kubectl -n kube-system get secret $TOKEN_NAME -o jsonpath="{.data.token}" | base64 -D # Note : kubectl describe gives us the token "raw", but in json output it is base64 encoded. byte[] handling magic.

echo ""
echo "(hit Ctrl-C when done)"
echo "You may want to watch for the deployments to be done with the following command in another terminal : KUBECONFIG=kube_config_cluster.yml watch -d -n 1 'kubectl get pods --all-namespaces -o wide'"
kubectl proxy

# Note : to restart flanneld : kubectl delete -n kube-system $(kubectl get pods -n kube-system -l k8s-app=flannel -o name)
