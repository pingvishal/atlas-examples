#!/bin/sh
exec /usr/sbin/apache2ctl start >> /var/log/apache2ctl.log 2>&1
