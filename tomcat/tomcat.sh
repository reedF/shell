#!/bin/sh
#################################################################################
#
#   Copyright 2004 The Apache Software Foundation.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   chkconfig: 345 88 14
#   description: Tomcat Daemon
#   processname: jsvc
#   单个应用tomcat实例启动停止脚本（使用jsvc监控）
#注：
#     1.使用前配置相关参数 
#     2.使用linux相关应用的帐号启动，切勿使用root帐号启动
#################################################################################
APP_NAME=应用名
APP_HOME=应用文件所在部署目录
APP_CONFIG_HOME=应用配置文件路径
APP_LOG_HOME=应用日志输出地址
export JAVA_HOME=/usr/local/jdk
export CATALINA_HOME=/usr/local/tomcat6
#应用tomcat实例配置地址
export CATALINA_BASE=${APP_CONFIG_HOME}/tomcat
export TOMCAT_USER=应用名
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/apr/lib
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export LANG=en_US.UTF-8
TMP_DIR=/tmp/${APP_NAME}
PID_FILE=${APP_HOME}/jsvc.pid
export DAEMON_HOME=${CATALINA_HOME}/bin/commons-daemon/unix

export CATALINA_OPTS="-Djvm.process.name=${APP_NAME} -Dapp.instance.config=${APP_CONFIG_HOME}
 -Dlog4j.configuration=file://${APP_CONFIG_HOME}/log4j.xml -Dapp.log.home=${APP_LOG_HOME} -Dnet.jawr.debug.on=false"

CLASSPATH=${CATALINA_HOME}/lib:\
$JAVA_HOME/lib/tools.jar:\
$CATALINA_HOME/bin/commons-daemon.jar:\
$CATALINA_HOME/bin/bootstrap.jar

case "$1" in
  start)
        ## remove cache
        #rm -rf ${CATALINA_HOME}/work/*
	    ##
	    ## Start Tomcat
	    ##
	    $DAEMON_HOME/jsvc \
	    -jvm server \
	    -user $TOMCAT_USER \
	    -home $JAVA_HOME \
	    -Dcatalina.home=$CATALINA_HOME \
	    -Dcatalina.base=$CATALINA_BASE \
	    $CATALINA_OPTS \
	    -Djava.io.tmpdir=$TMP_DIR \
	    -wait 30 \
	    -pidfile $PID_FILE \
	    -outfile ${APP_LOG_HOME}/jsvc.log \
	    -errfile ${APP_LOG_HOME}/jsvc.log \
	    -Xmx2048m -Xms1024m -Xmn512m -Xss512k -XX:PermSize=256m -XX:SurvivorRatio=8 -XX:ParallelGCThreads=20 \
        -XX:ParallelCMSThreads=20 -XX:+UseConcMarkSweepGC -XX:+UseCMSCompactAtFullCollection \
        -XX:CMSFullGCsBeforeCompaction=5 -XX:CMSInitiatingOccupancyFraction=70 -XX:+PrintClassHistogram \
	    -cp $CLASSPATH \
	    org.apache.catalina.startup.Bootstrap
	    echo "Tomcat Server Start [ OK ]"
	    exit $?
	   ;;

  stop)
	    ##
	    ## Stop Tomcat
	    ##
	    $DAEMON_HOME/jsvc \
	    -stop \
	    -pidfile $PID_FILE \
	    org.apache.catalina.startup.Bootstrap
	    echo "Tomcat Server Stop [ OK ]"
	    exit $?
	    ;;

  *)
	    echo "Usage tomcat start/stop"
	    exit 1;;
esac
