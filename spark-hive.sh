#!/usr/bin/env bash

# ��Ⱥ��ʽ
MASTER=yarn
# ����ģʽ
DEPLOY_MODE=cluster
#DEPLOY_MODE=client
# Ӧ������
MAIN_NAME=spark-hive
# Ӧ������
MAIN_CLASS=com.embraces.spark.sql.hive.SparkHiveAPP

cd `dirname $0`

# Ӧ��jar��
MAIN_JAR="./spark-hive-0.0.1-SNAPSHOT.jar"
# ������·��
PATH_LIB=.
JARS=`ls $PATH_LIB/*.jar | head -1`

for jar in `ls $PATH_LIB/*.jar | grep -v $PROJECT | grep -v $JARS`
do
  JARS="$JARS,""$jar"
done

set -x

# ���Ӧ���Ѿ����������ȹر�Ӧ��
appId=`yarn application -list | grep $MAIN_NAME | awk '{print $1}'`
for id in $appId
do
   echo "kill app "$id
   yarn application -kill $id
done

# �ύӦ��
nohup /usr/hdp/2.6.0.3-8/spark2/bin/spark-submit \
--name $MAIN_NAME \
--class $MAIN_CLASS \
--master $MASTER     \
--files conf/log4j.properties,krb5.ini,hive.service.keytab  \
--driver-java-options "-Dappname=$MAIN_NAME -Dmaster=$MASTER -Dlog4j.configuration=log4j.properties" \
--conf "spark.executor.extraJavaOptions=-Dappname=$MAIN_NAME -Dlog4j.configuration=log4j.properties"   \
--conf "spark.default.parallelism=36"   \
--conf "spark.streaming.concurrentJobs=10"   \
--conf "spark.sql.shuffle.partitions=100"   \
--conf "spark.yarn.executor.memoryOverhead=1024"   \
--conf "spark.streaming.blockInterval=10000ms"   \
--conf "spark.serializer=org.apache.spark.serializer.KryoSerializer"   \
--conf "spark.scheduler.mode=FAIR"   \
--deploy-mode $DEPLOY_MODE     \
--driver-memory 1g     \
--num-executors 1 \
--executor-cores 2     \
--executor-memory 1g     \
--queue default     \
--jars $JARS   $MAIN_JAR 1>out.log 2>err.log &
