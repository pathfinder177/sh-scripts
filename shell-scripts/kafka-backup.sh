#!/bin/bash

#Задайте переменные локальной Kafka, куда мы копируем данные
export LOCAL_KAFKA={{groups['backup_node'][0]}}:9092
export LOCAL_ZK={{groups['backup_node'][0]}}:2181
#Задайте переменные кластерной Kafka, откуда мы копируем данные
export CLUSTER_KAFKA={{groups['kafka_nodes'][0]}}:9092
export CLUSTER_ZK={{groups['zookeeper_nodes'][0]}}:2181

export PATH=$PATH:/opt/kafka/bin
export KAFKA_HEAP_OPTS="-Xmx1g"

if [ -z $1 ]; then
    echo "Вы не ввели Secret ID!"
    exit 1
fi

kafka-topics.sh --list --zookeeper=${CLUSTER_ZK} | grep [^[*] > topics
echo -e "\e[1;32m При наличии сообщений в топике будут скопированы следующие топики \e[0m"
cat topics
echo
sleep 5

#Копируем все топики в локальную Kafka
echo -e "\e[1;32m Начало реплицирования топиков \e[0m"
kafka-mirror-maker.sh --consumer.config backup-consumer.properties --producer.config backup-producer.properties --num.streams 5 --whitelist ".*"
echo -e "\e[1;32m Топики с сообщениями были скопированы в $LOCAL_KAFKA \e[0m"
echo
echo -e "\e[1;32m Список скопированных топиков \e[0m"
kafka-topics.sh --list --zookeeper=${LOCAL_ZK}
