---
layout: post
title: "how to write standard startup script"
date: 2016-08-22 09:09:06 +0800
comments: true
categories: linux
---

## systemV init script template
```
#!/bin/bash

# sdpmclient - Startup script for sdpmclient

# chkconfig: 35 85 15
# description: sdpmclient is your openstack VMS monitor and ovs auto config bot.
# processname: sdpmclient
# config: /etc/sdpmclient.conf

. /etc/rc.d/init.d/functions

# NOTE: if you change any OPTIONS here, you get what you pay for:
# this script assumes all options are in the config file.
CONFIGFILE="/etc/sdpmclient.conf"

SDPMCLIENT=/usr/local/bin/sdpmclient

SDPMCLIENT_USER=netissdpm
SDPMCLIENT_GROUP=netissdpm

# things from sdpmclient.conf get there by sdpmclient reading it
PIDFILEPATH=`awk -F'[:=]' -v IGNORECASE=1 '/^[[:blank:]]*(processManagement\.)?pidFilePath[[:blank:]]*[:=][[:blank:]]*/{print $2}' "$CONFIGFILE" | tr -d "[:blank:]\"'" | aw
PIDDIR=`dirname $PIDFILEPATH`
LOGFILEPATH=`awk -F'[:=]' -v IGNORECASE=1 '/^[[:blank:]]*(processManagement\.)?logFilePath[[:blank:]]*[:=][[:blank:]]*/{print $2}' "$CONFIGFILE" | tr -d "[:blank:]\"'" | aw
LOGDIR=`dirname $LOGFILEPATH`

OPTIONS=" -c $CONFIGFILE"

start()
{
  # Make sure the default pidfile directory exists
  if [ ! -d $PIDDIR ]; then
    install -d -m 0755 -o $SDPMCLIENT_USER -g $SDPMCLIENT_GROUP $PIDDIR
  fi
  if [ ! -d $LOGDIR ]; then
    install -d -m 0755 -o $SDPMCLIENT_USER -g $SDPMCLIENT_GROUP $LOGDIR
  fi

  echo -n $"Starting sdpmclient: "
  daemon --pidfile "$PIDFILEPATH" --user "$SDPMCLIENT_USER" --check $SDPMCLIENT "$SDPMCLIENT $OPTIONS >$LOGFILEPATH 2>&1 &"

  RETVAL=$?
  pid=`ps -A x | grep $SDPMCLIENT | grep -v grep | cut -d" " -f1 | head -n 1`
  if [ -n "$pid" ]; then
          echo $pid > $PIDFILEPATH
  fi

  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/sdpmclient
  echo
  return $RETVAL
}

stop()
{
  echo -n $"Stopping sdpmclient: "
  sdpmclient_killproc "$PIDFILEPATH" $SDPMCLIENT
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/sdpmclient
}

restart () {
        stop
        start
}

# Send TERM signal to process and wait up to 300 seconds for process to go away.
# If process is still alive after 300 seconds, send KILL signal.
# Built-in killproc() (found in /etc/init.d/functions) is on certain versions of Linux
# where it sleeps for the full $delay seconds if process does not respond fast enough to
# the initial TERM signal.
sdpmclient_killproc()
{
  local pid_file=$1
  local procname=$2
  local -i delay=10
  local -i duration=1
  local pid=`pidofproc -p "${pid_file}" ${procname}`

  kill -TERM $pid >/dev/null 2>&1
  usleep 1000
  local -i x=0
  while [ $x -le $delay ] && checkpid $pid; do
    sleep $duration
    x=$(( $x + $duration))
  done

  kill -KILL $pid >/dev/null 2>&1
  usleep 1000

  checkpid $pid # returns 0 only if the process exists
  local RC=$?
  [ "$RC" -eq 0 ] && failure "${procname} shutdown" || rm -f "${pid_file}"; success "${procname} shutdown"
  RC=$((! $RC)) # invert return code so we return 0 when process is dead.
  return $RC
}

RETVAL=0

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart|reload|force-reload)
    restart
    ;;
  condrestart)
    [ -f $PIDFILEPATH] && restart || :
    ;;
  status)
    status $SDPMCLIENT
    RETVAL=$?
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
    RETVAL=1
esac

exit $RETVAL
```


## systemd startup script
```
[config]
server = tcp://localhost:35555
node = 1
heartbeat_period = 5
port_sync_period = 10
config_period = 60
ovslog_filepath = /var/lib/netissdpm/log/sdpmovs.log
ovslog_maxbytes = 10485760

[system]
pidFilePath=/var/lib/netissdpm/run/sdpmclient.pid
logFilePath=/var/lib/netissdpm/log/sdpmclient.log
```
