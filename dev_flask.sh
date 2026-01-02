#!/bin/bash

APP_DIR="/home/ubuntu/flask-app"
PID_FILE="$APP_DIR/flask.pid"
LOG_FILE="$APP_DIR/flask.log"

start() {
  cd $APP_DIR
  nohup python3 app.py > $LOG_FILE 2>&1 &
  echo $! > $PID_FILE
}

stop() {
  if [ -f $PID_FILE ]; then
    kill $(cat $PID_FILE) || true
    rm -f $PID_FILE
  fi
}

restart() {
  stop
  sleep 1
  start
}

case "$1" in
  start|stop|restart) $1 ;;
  *) echo "Usage: $0 {start|stop|restart}" ;;
esac