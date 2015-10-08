#!/bin/bash

echo "${SERVER_ID} / ${MAX_SERVERS}" 

if [ ! -z "${SERVER_ID}" ] && [ ! -z "${MAX_SERVERS}" ]; then
  echo "Starting up in clustered mode"
  echo "" >> /opt/zookeeper/conf/zoo.cfg
  echo "#Server List" >> /opt/zookeeper/conf/zoo.cfg
  for i in $(eval echo {1..${MAX_SERVERS}});do
    ZK_SVC=ZOOKEEPER_${i}_SERVICE_HOST
    if [[ ${!ZK_SVC} == "" ]]; then
      echo "zookeeper-$i service must be created before starting pods..."
      sleep 30 # To postpone pod restart
      exit 1
    fi
    if [ $i -eq ${SERVER_ID} ]; then
      echo "server.$i=0.0.0.0:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    else      
      echo "server.$i=${!ZK_SVC}:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    fi
  done
  cat /opt/zookeeper/conf/zoo.cfg
  echo ""

  # Persists the ID of the current instance of Zookeeper
  echo ${SERVER_ID} > /zookeeper_data/data/myid
else
  echo "Starting up in standalone mode"
fi

# wait until counterpart services' endpoints ready 
# endpoints of a k8s service may be unavailable to query via apiserver right after pod creation...  
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
for i in $(eval echo {1..${MAX_SERVERS}}); do
  if [ $i -ne ${SERVER_ID} ]; then
    # curl -m: max operation timeout; -Ss: hide progress meter but show error; --stderr -: redirect all writes to stdout
    RET=$(curl -m 2 -Ss --stderr - -k https://${KUBERNETES_SERVICE_HOST}/api/v1/namespaces/${POD_NAMESPACE}/endpoints/zookeeper-$i -H "Authorization: Bearer ${KUBE_TOKEN}" | jq -r '.subsets[0].addresses[0].ip != null')
    while [ ${RET} != true ]; do
      echo "Endpoint of counterpart services zookeeper-$i is not ready...(RET=${RET})"
      sleep 2
      RET=$(curl -m 2 -Ss --stderr - -k https://${KUBERNETES_SERVICE_HOST}/api/v1/namespaces/${POD_NAMESPACE}/endpoints/zookeeper-$i -H "Authorization: Bearer ${KUBE_TOKEN}" | jq -r '.subsets[0].addresses[0].ip != null')
    done
  fi
done
echo "Endpoint(s) of counterpart services have been ready!" 

exec /opt/zookeeper/bin/zkServer.sh start-foreground
