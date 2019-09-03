#!/bin/bash

cd `dirname $0`
cd ..
DEPLOY_DIR=`pwd`
BIN_DIR="$DEPLOY_DIR"/bin
PROFILE=""
JARFILE=$(ls *.jar)
SERVER=$(echo "$JARFILE" | sed 's/\.[^.]*$//')

# JAVA
check_java_env() {
    if [ -x "$JAVA_HOME/bin/java" ]; then
        JAVA="$JAVA_HOME/bin/java"
    else
        JAVA=`which java`
    fi

    if [ ! -x "$JAVA" ]; then
        echo "Could not find any executable java binary. Please install java in your PATH or set JAVA_HOME"
        exit 1
    fi
}

# JAVA_OPTS
parse_jvm_options() {
    jvm_options="$BIN_DIR"/jvm-"$PROFILE".options
    if [ -f "$jvm_options" ]; then
        echo "$(grep "^-" "$jvm_options" | tr '\n' ' ')"
    fi
}

function running(){
	if [ -n "$JARFILE" ]; then
		pid=`ps -ef | grep "$JARFILE" | grep -v grep | awk '{ print $2 }'`
		if [ -z "$pid" ]; then
		    return 1;
		else
			return 0;
		fi
	else
		return 1
	fi
}

function start_server() {
    check_profile_env
	if running; then
		echo "server [$SERVER] is already running ..."
		exit 1
	fi
	JAVA_OPTS="$(parse_jvm_options) $JAVA_OPTS"

    echo "nohup java ${JAVA_OPTS} -jar -Dspring.profiles.active=${PROFILE} ${JARFILE} >/dev/null 2>&1 &"
    nohup java ${JAVA_OPTS} -jar -Dspring.profiles.active=${PROFILE} ${JARFILE} >/dev/null 2>&1 &
    echo "server [$SERVER] start..."
  	sleep 1;
}

function stop_server() {
	if ! running; then
		echo "server is not running ..."
		exit 1
	fi
	pid=`ps -ef | grep "$JARFILE" | grep -v grep | awk '{ print $2 }' | tr -s '\n' ' '`
    kill -9 $pid
    echo "server [$SERVER] stop finished !"
}

function status(){

    if running; then
       echo "server [$SERVER] is running ...";
       exit 0;
    else
       echo "server [$SERVER] was stopped ...";
       exit 1;
    fi
}

function check_profile_env() {
    if [ -z "$PROFILE" ]; then
        help
        exit 1;
    fi
}

function restart_server() {
    check_profile_env
    stop_server
    start_server
}
 
function help() {
    echo "Usage: server_auto.sh {start|stop|restart|status} [ENV]" >&2
    echo "       start:             start the server server"
    echo "       stop:              stop the server server"
    echo "       restart:           restart the server server"
    echo "       status:            get server current status,running or stopped."
	echo "       ENV:               the environment(dev|test|show|prod)"
}

if [[ "$#" < 1 ]]; then
    help
    exit 1
fi

command=$1
PROFILE=$2
case $command in
    start)
        start_server;
        ;;    
    stop)
        stop_server;
        ;;
    restart)
        restart_server;
        ;;
    status)
    	status;
        ;; 
    help)
        help;
        ;;
    *)
        help;
        exit 1;
        ;;
esac