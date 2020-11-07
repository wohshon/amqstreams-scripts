# amqstreams-scripts

Convenient scripts to setup a amq streams (apache kafka) deployment on Openshift Container Platform using the strimizi operators

This is for my own demo setup so please adjust the parameters accordingiy if you need to use it.

It assumes you have access to a OCP cluster, with cluster admin rights.

The yaml files in the `install` directory deploys a strimzi operator in the current namespace specified in the `$NS` variable.

The yaml files in `crd/c1` and `crd/c2` are for deploying 2 separate kafka clusters.
It consist of a barebone Kafka cluster (exposing a route) and 2 topics.

To deploy the cluster, the scripts are as follows

```
export NS=amqstream
oc apply -f install/strimzi-admin
sed -i 's/namespace: .*/namespace: '$NS'/' install/cluster-operator/*RoleBinding*.yaml
oc apply -f install/cluster-operator -n $NS
oc apply -f crd/c1
```
