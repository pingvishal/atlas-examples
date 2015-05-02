#!/bin/bash

exec /usr/bin/consul-template \
    -consul 127.0.0.1:8500 \
    -template "/ops/templates/httpd.ctmpl:/etc/apache2/conf/test_httpd.conf:sudo service apache2 restart" >> /var/log/ctemplate.log 2>&1
