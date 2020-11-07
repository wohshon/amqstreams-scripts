#!/bin/bash
if [ $# -ne 3 ]
  then
    echo "Enter the following parameters:"
    echo "- namespace"
    echo "- cluster name" 
    echo "- topic name" 
    exit 1
fi


#set the namespace name
NS=$1
#set the kafka cluster name
CLUSTER_NAME=$2
#set the topic name
TOPIC_NAME=$3


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

