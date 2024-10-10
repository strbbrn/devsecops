#!/bin/bash

# Gunicorn service management script

GUNICORN_USER="userid"
DEPLOY_DIR="/local/DeploymentFun"
PID_FILE="$DEPLOY_DIR/guni.pid"
ACCESS_LOG="$DEPLOY_DIR/logs/access.txt"
ERROR_LOG="$DEPLOY_DIR/logs/log.txt"
GUNICORN_CMD="gunicorn --workers=12 --access-logfile=$ACCESS_LOG --error-logfile=$ERROR_LOG --capture-output web_deploy:app -p $PID_FILE -b 0.0.0.0:8000"

case "$1" in

    start)
        echo "Starting Gunicorn..."
        su $GUNICORN_USER -c "cd $DEPLOY_DIR && $GUNICORN_CMD"
        echo "Gunicorn started."
        ;;
    
    stop)
        echo "Stopping Gunicorn..."
        if [ -e "$PID_FILE" ]; then
            kill `cat $PID_FILE`
            echo "Gunicorn stopped."
        else
            echo "Gunicorn PID file not found. Is it running?"
        fi
        ;;
    
    restart)
        $0 stop
        $0 start
        ;;
    
    status)
        if [ -e "$PID_FILE" ]; then
            echo "Gunicorn service is running, pid=`cat $PID_FILE`"
        else
            echo "Gunicorn service is NOT running."
            exit 1
        fi
        ;;
    
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
