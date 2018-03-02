#!/bin/bash

# type can be a job or daemonset
type=$1
if [[ "$#" -ne 1 ]]; then
  echo "syntax: $0 <TYPE>"
  echo "<TYPE> should be either job or daemonset"
  exit 1
fi

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

# create a namespace with the default nodeselector set to empty string
oc create -f openshift_templates/create-namespace.yaml
oc project node-feature-discovery 

# create a role and binding to allow default user to view the pods in node-feature-discovery namespace
oc create -f openshift_templates/rbac.yaml

# add privileged scc to user
oc adm policy add-scc-to-user privileged -z default -n node-feature-discovery

if [[ $type == "job" ]]; then
	# get node count in openshift cluster
	node_count=$(oc get nodes | grep -w Ready | wc -l)
	# set completion and parallelism count
	sed -e "s/COUNT/$node_count/" openshift_templates/node-feature-discovery-template.yaml > openshift_templates/node-feature-discovery.yaml
	# create pods using the job template
	oc create -f openshift_templates/node-feature-discovery.yaml
elif [[ $type == "daemonset" ]]; then
	# create a daemonset
	oc create -f openshift_templates/node-feature-discovery-daemonset.yaml
else
	echo "$type is not a valid option, it needs to be either job or daemonset"
	exit 1
fi
