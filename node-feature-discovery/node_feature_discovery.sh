#!/bin/bash

# check for kubeconfig
if [[ ! -s $HOME/.kube/config ]]; then
	echo "cannot find kube config in the home directory, please check"
	exit 1
fi

# check if oc client is installed
echo "Checking if oc client is installed"
which oc &>/dev/null
if [[ $? != 0 ]]; then
	echo "oc client is not installed"
	exit 1
fi

# create a namespace
oc new-project node-feature-discovery

# add privileged scc to user
oc adm policy add-scc-to-user privileged -z default -n node-feature-discovery

# get node count in openshift cluster
node_count=$(oc get nodes | grep -i ready | wc -l)

# create a role and binding to allow default user to view the pods in node-feature-discovery namespace
oc create -f openshift_templates/rbac.yaml 

# set completion and parallelism count
sed -e "s/COUNT/$node_count/" openshift_templates/node-feature-discovery-template.yaml > openshift_templates/node-feature-discovery.yaml

# create pods
oc create -f openshift_templates/node-feature-discovery.yaml
