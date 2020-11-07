#!/bin/bash
cp crd/mm2-template -rf crd/working/
mv crd/working/mm2-template crd/working/mm2
echo "This script only helps to build up the mm2 yaml file"
C1_NAME=cluster1
C2_NAME=cluster2
DOMAIN1=apps.ocpcluster1.$MYDOMAIN.com
DOMAIN2=apps.ocpcluster2.$MYDOMAIN.com
BOOTSTRAP_URL1=kafka-bootstrap
BOOTSTRAP_URL2=kafka-bootstrap
NS1=amqstreams
NS2=amqstreams
ROUTE1=$C1_NAME-$BOOTSTRAP_URL1-$NS1.$DOMAIN1:443
ROUTE2=$C2_NAME-$BOOTSTRAP_URL2-$NS2.$DOMAIN2:443
CERT_NAME=ca.crt
SECRET1=$C1_NAME-cluster-ca-cert
SECRET2=$C2_NAME-cluster-ca-cert
C1_ALIAS=$C1_NAME
C2_ALIAS=$C2_NAME

echo "creating mm2 yaml on c2 for the usecase:"
echo $C1_NAME " -> " $C2_NAME
sed -i 's/alias: c1/alias: '$C1_ALIAS'/' crd/working/mm2/mm2.yaml 
sed -i 's/alias: c2/alias: '$C2_ALIAS'/' crd/working/mm2/mm2.yaml 
sed -i 's/certificate: c1/certificate: '$CERT_NAME'/' crd/working/mm2/mm2.yaml 
sed -i 's/secretName: c1/secretName: '$SECRET1'/' crd/working/mm2/mm2.yaml 
sed -i 's/certificate: c2/certificate: '$CERT_NAME'/' crd/working/mm2/mm2.yaml 
sed -i 's/secretName: c2/secretName: '$SECRET2'/' crd/working/mm2/mm2.yaml 
sed -i 's/connectCluster: .*/connectCluster: '$C2_NAME'/' crd/working/mm2/mm2.yaml
sed -i 's/bootstrapServers: c1/bootstrapServers: '$ROUTE1'/' crd/working/mm2/mm2.yaml
sed -i 's/bootstrapServers: c2/bootstrapServers: '$ROUTE2'/' crd/working/mm2/mm2.yaml
sed -i 's/sourceCluster: .*/sourceCluster: '$C1_NAME'/' crd/working/mm2/mm2.yaml 
sed -i 's/targetCluster: .*/targetCluster: '$C2_NAME'/' crd/working/mm2/mm2.yaml 
