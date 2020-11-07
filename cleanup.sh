#!/bin/bash
if [ $# -ne 1 ]
  then
    echo "namespace to clean up required"
    exit 1
fi
NS=$1
echo 'cleaning up namespace '$NS
sed -i 's/name: .*/name: ''/' crd/cluster_template/kafka-broker.yaml
sed -i 's/namespace: .*/namespace: ''/' crd/cluster_template/kafka-broker.yaml
sed -i 's/strimzi.io\/cluster: .*/strimzi.io\/cluster: ''/' crd/cluster_template/kafka-topic.yaml
sed -i 's/namespace: .*/namespace: ''/' crd/cluster_template/kafka-topic.yaml
sed -i 's/topicName: .*/topicName: ''/' crd/cluster_template/kafka-topic.yaml
sed -i 's/name: .*/name: ''/' crd/cluster_template/kafka-topic.yaml

oc delete project $NS
