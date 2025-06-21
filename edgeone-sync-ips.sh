#!/bin/bash

EDGEONE_FILE_PATH=${1:-/etc/nginx/edgeone}

echo "#EdgeOne" > $EDGEONE_FILE_PATH;
echo "" >> $EDGEONE_FILE_PATH;

echo "# - IPv4" >> $EDGEONE_FILE_PATH;
for i in `curl -s -L https://api.edgeone.ai/ips?version=v4`; do
        echo "set_real_ip_from $i;" >> $EDGEONE_FILE_PATH;
done

echo "" >> $EDGEONE_FILE_PATH;
echo "# - IPv6" >> $EDGEONE_FILE_PATH;
for i in `curl -s -L https://api.edgeone.ai/ips?version=v6`; do
        echo "set_real_ip_from $i;" >> $EDGEONE_FILE_PATH;
done

echo "" >> $EDGEONE_FILE_PATH;
echo "real_ip_header EO-Connecting-IP;" >> $EDGEONE_FILE_PATH;

#test configuration and reload nginx
nginx -t && systemctl reload nginx
