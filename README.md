# amqstreams-scripts

Convenient scripts to setup a amq streams (apache kafka) deployment on Openshift Container Platform using the strimizi operators

This is for my own demo setup so please adjust the parameters accordingiy if you need to use it.

It assumes you have access to a OCP cluster, with cluster admin rights.

The yaml files in the `install` directory deploys a strimzi operator in the current namespace specified in the `$NS` variable.

The `crd/cluster_template` directory contains definition for  deploying a barebone kafka cluster with an exposed route;  and a topic.

To deploy the cluster, the scripts are as follows:

You can also run the `./deploy.sh` script:

	$ ./deploy.sh amqstreams my-cluster mytopic 

```
#set the namespace name
NS=amqstream
#set the kafka cluster name
CLUSTER_NAME=my-cluster
#set the topic name
TOPIC_NAME=mytopic


oc new-project $NS

# update the operator installer yaml with namespace
sed -i 's/namespace: .*/namespace: '$NS'/' install/cluster-operator/*RoleBinding*.yaml
# install operator
oc apply -f install/strimzi-admin
oc apply -f install/cluster-operator -n $NS


# duplicate the crd to a working folder
cp crd/cluster_template crd/$CLUSTER_NAME -rf

# set cluster name in broker
sed -i 's/name: .*/name: '$CLUSTER_NAME'/' crd/$CLUSTER_NAME/kafka-broker.yaml
sed -i 's/namespace: .*/namespace: '$NS'/' crd/$CLUSTER_NAME/kafka-broker.yaml

# set parent cluster and topic name 
sed -i 's/strimzi.io\/cluster: .*/strimzi.io\/cluster: '$CLUSTER_NAME'/' crd/$CLUSTER_NAME/kafka-topic.yaml
sed -i 's/namespace: .*/namespace: '$NS'/' crd/$CLUSTER_NAME/kafka-topic.yaml
sed -i 's/name: .*/name: '$TOPIC_NAME'/' crd/$CLUSTER_NAME/kafka-topic.yaml
sed -i 's/topicName: .*/topicName: '$TOPIC_NAME'/' crd/$CLUSTER_NAME/kafka-topic.yaml

oc apply -f crd/$CLUSTER_NAME
```
- Cleanup, reset all the template files and delete the project, you can also run the `cleanup.sh`

```
# Clean up

sed -i 's/name: .*/name: ''/' crd/cluster_template/kafka-broker.yaml
sed -i 's/namespace: .*/namespace: ''/' crd/cluster_template/kafka-broker.yaml
sed -i 's/strimzi.io\/cluster: .*/strimzi.io\/cluster: ''/' crd/cluster_template/kafka-topic.yaml
sed -i 's/namespace: .*/namespace: ''/' crd/cluster_template/kafka-topic.yaml
sed -i 's/topicName: .*/topicName: ''/' crd/cluster_template/kafka-topic.yaml
sed -i 's/name: .*/name: ''/' crd/cluster_template/kafka-topic.yaml

oc delete project $NS
```
- some mm2 templates and sample  in `crd/mm2`

`sed -i 's/alias: c1/alias: '$C1_ALIAS'/' crd/mm2/mm2.yaml`   ... 

