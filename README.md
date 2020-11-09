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
mkdir crd/working/
cp crd/working/cluster_template crd/$CLUSTER_NAME -rf

# set cluster name in broker
sed -i 's/name: .*/name: '$CLUSTER_NAME'/' crd/working/$CLUSTER_NAME/kafka-broker.yaml
sed -i 's/namespace: .*/namespace: '$NS'/' crd/working/$CLUSTER_NAME/kafka-broker.yaml

# set parent cluster and topic name 
sed -i 's/strimzi.io\/cluster: .*/strimzi.io\/cluster: '$CLUSTER_NAME'/' crd/working/$CLUSTER_NAME/kafka-topic.yaml
sed -i 's/namespace: .*/namespace: '$NS'/' crd/working/$CLUSTER_NAME/kafka-topic.yaml
sed -i 's/name: .*/name: '$TOPIC_NAME'/' crd/working/$CLUSTER_NAME/kafka-topic.yaml
sed -i 's/topicName: .*/topicName: '$TOPIC_NAME'/' crd/working/$CLUSTER_NAME/kafka-topic.yaml

oc apply -f crd/working/$CLUSTER_NAME
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

rm crd/working -rf
oc delete project $NS


```

#### Mirror Maker 2 

- some mm2 templates and sample  in `crd/mm2`

use `create-mm2-yaml.sh` to create a mm2 config. It assumes all secret names and service names are default, and MM2 is to  be deployed on 'cluster 2'

the output at `crd/mm2/working/mm2.yaml` will be ready for **manual** deployment, so check the appropriate secrets and certs are in place (see following sections)

For bidirectional, you just have to reverse the source and target cluster configs accordingly

Some handy commands to ensure you have the secrets setup :

- if MM2 is on cluster 2, create the secrets from cluster 1 

//login to cluster 1, then extract secret to be created on cluster 2

On cluster1
```
oc extract secret/cluster1-cluster-ca-cert --keys=ca.p12 --to=- > /tmp/source-ca-certs/ca.p12
oc extract secret/cluster1-cluster-ca-cert --keys=ca.password --to=- > /tmp/source-ca-certs/ca.password
oc extract secret/cluster1-cluster-cluster-ca-cert --keys=ca.crt --to=- > /tmp/source-ca-certs/ca.crt
```

Then on cluster2
```
oc create secret generic cluster1-cluster-ca-cert  --from-file=/tmp/source-ca-certs/ca.crt --from-file=/tmp/source-ca-certs/ca.p12 --from-file=/tmp/source-ca-certs/ca.password

``` 

-trust stores for java clients (eg. the kafka producer / consumer tools)
e.g:
 
```
keytool -import -trustcacerts -alias root -file /tmp/source-ca-certs/ca.crt -keystore target-truststore.jks -storepass password -noprompt
```

- sample clients using the external route, (adjust the path / truststore names according to your env)

```
./kafka_2.12-2.5.0.redhat-00003/bin/kafka-console-producer.sh --bootstrap-server my-cluster-target-kafka-bootstrap-amqstreams.apps.ocpcluster2.domain.com:443 --producer-property security.protocol=SSL --producer-property ssl.truststore.password=password --producer-property ssl.truststore.location=./target-truststore.jks --topic mm2-topic
```
