#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="Gitea"
QPKG_ROOT=$(/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF})
APACHE_ROOT=/share/$(/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info)

QPKG_NAME2="QGit"
QPKG_ROOT2=$(/sbin/getcfg $QPKG_NAME2 Install_Path -f ${CONF})

GIT_HOME=$(getent passwd git |cut -d: -f 6)

export QPKG_ROOT QPKG_ROOT2 GIT_HOME

export LOGPATH=${QPKG_ROOT}/log
export LOGFILE=${LOGPATH}/error.log
export PATH=$QPKG_ROOT2/bin:$PATH
export LC_ALL=en_US.UTF-8
export SHELL=/bin/sh
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    mkdir -p $LOGPATH
    ln -sf $QPKG_ROOT /opt/Gitea
    chown -R git:everyone $QPKG_ROOT/log $QPKG_ROOT/conf/app.ini
    mkdir -p ${GIT_HOME}
    chown git:everyone ${GIT_HOME}
    chown -R git:everyone ${GIT_HOME}/.ssh 2>/dev/null
    chmod 755 ${GIT_HOME}
    ln -sf ${GIT_HOME} /opt
    cd $QPKG_ROOT
    $QPKG_ROOT/bin/su-exec git $QPKG_ROOT/bin/gitea web --config $QPKG_ROOT/conf/app.ini 2>&1 >>${LOGFILE} &
    ;;

  stop)
    killall -9 gitea
    rm -f /opt/Gitea /opt/git 
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
