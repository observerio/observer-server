#!/bin/sh
set -e

echo 'Begin kube admin init'
kubeadm init --config /tmp/master-configuration.yml
echo 'Done kube admin init'

echo 'Begin kube admin create token'
kubeadm token create ${token}
echo 'Done kube admin create token'

echo 'Begin setup configuration'
[ -d $HOME/.kube ] || mkdir -p $HOME/.kube
ln -s /etc/kubernetes/admin.conf $HOME/.kube/config
echo 'Done setup configuration'

until $(curl --output /dev/null --silent --head --fail http://localhost:6443); do
  echo "Waiting for API server to respond"
  sleep 5
done

kubectl apply -f https://git.io/weave-kube-1.6

kubectl -n kube-system get ds -l 'k8s-app=kube-proxy' -o json \
  | jq '.items[0].spec.template.spec.containers[0].command |= .+ ["--proxy-mode=userspace"]' \
  | kubectl apply -f - && kubectl -n kube-system delete pods -l 'k8s-app=kube-proxy'

# See: https://kubernetes.io/docs/admin/authorization/rbac/
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
