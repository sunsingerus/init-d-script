#!/bin/bash
### BEGIN INIT INFO
# Provides:          <NAME>
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: <SHORT DESCRIPTION>
# Description:       <DESCRIPTION>
### END INIT INFO


SERVICE_NAME=$(basename $0)
RUN_CMD="sleep 100"
#IS_CMD_CAPABLE="yes"
IS_CMD_CAPABLE="no"

PID_FILE=/var/run/${SERVICE_NAME}/${SERVICE_NAME}.pid
LOG_FILE=/var/log/${SERVICE_NAME}/${SERVICE_NAME}.log
RUN_CMD_AS_USER=root
WORK_DIR=/
SOFT_STOP_SIGNAL=SIGINT
HARD_STOP_SIGNAL=SIGKILL
DEBUG="no"
DEBUG="yes"


function is_root()
{
	[ "$EUID" -eq 0 ]
}

function get_pid()
{
	[ -f "$PID_FILE" ] && cat "$PID_FILE"
}

function delete_pid_file()
{
	if [ -f "$PID_FILE" ]; then
		rm "$PID_FILE"
	fi
}

function is_running()
{
	kill -0 $(get_pid) &> /dev/null
}

function start_capable_service()
{
	sudo -u $RUN_CMD_AS_USER bash -c "$RUN_CMD"
}

function start_incapable_service()
{
	local CMD="${RUN_CMD} &> \"$LOG_FILE\" & echo \$! > \"$PID_FILE\""
	sudo -u $RUN_CMD_AS_USER bash -c "$CMD"
}

function start()
{
	if is_running; then
		echo -n "$SERVICE_NAME already running as: "
		ps -p $(get_pid)
		echo
		exit 1
	fi

	echo "Starting $SERVICE_NAME"
	cd $WORK_DIR

	if [ $IS_CMD_CAPABLE == "yes" ]; then
		start_capable_service
	else
		start_incapable_service
	fi

	cd -

	if ! is_running; then
		echo "ERROR: unable to start $SERVICE_NAME"
		echo "Check log file(s)"
		echo $LOG_FILE
		exit 1
	fi
}

function stop()
{
	STOP_SIGNAL=$1

	if ! is_running; then
		echo "$SERVICE_NAME is not running"
		exit 1
	fi

	echo "Send ${STOP_SIGNAL} to $SERVICE_NAME"
	kill -${STOP_SIGNAL} $(get_pid)

	echo "Wait for $SERVICE_NAME to exit"
	while is_running; do
		echo -n '.'
		sleep 1
	done
	echo "$SERVICE_NAME is not running"

	delete_pid_file
}

function stop_soft()
{
	stop $SOFT_STOP_SIGNAL
}

function stop_hard()
{
	stop $HARD_STOP_SIGNAL
}

function restart()
{
	stop
	start
}

if [ "$DEBUG" == "yes" ]; then
	set -x
fi

if ! is_root; then
	echo "Please run as root"
	exit 1
fi

case "$1" in
	start)
		start
		;;
	stop)
		stop_soft
		;;
	stop_hard)
		stop_hard
		;;
	retart)
		restart
		;;
	*)
		echo "Usage: $0 {start|stop|stop_hard|restart}"
esac

