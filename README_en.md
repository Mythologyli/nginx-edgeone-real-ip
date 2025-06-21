# Get Real Visitor IP Address (Restoring Visitor IPs) with Nginx and EdgeOne

[中文](README.md)

This project is modified based on [nginx-cloudflare-real-ip](https://github.com/ergin/nginx-cloudflare-real-ip). Many thanks to the original author, [ergin](https://github.com/ergin).

----

This project aims to modify your nginx configuration to let you get the real ip address of your visitors for your web applications that behind of EdgeOne's reverse proxy network. Bash script can be scheduled to create an automated up-to-date EdgeOne ip list file.

To provide the client (visitor) IP address for every request to the origin, EdgeOne adds the "EO-Connecting-IP" header. We will catch the header and get the real ip address of the visitor.

## Nginx Configuration
With a small configuration modification we can integrate replacing the real ip address of the visitor instead of getting EdgeOne's load balancers' ip addresses.

Open "/etc/nginx/nginx.conf" file with your favorite text editor and just add the following lines to your nginx.conf inside http{....} block.

```nginx
include /etc/nginx/edgeone;
```

The bash script may run manually or can be scheduled to refresh the ip list of EdgeOne automatically.
```sh
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
```

## Output
Your "/etc/nginx/edgeone" file may look like as below;

```nginx
#EdgeOne ip addresses

# - IPv4
set_real_ip_from ...;
set_real_ip_from ...;
...

# - IPv6
set_real_ip_from ...;
set_real_ip_from ...;
...

real_ip_header EO-Connecting-IP;

```

## Crontab
Change the location of "/opt/scripts/edgeone-ip-whitelist-sync.sh" anywhere you want. 
EdgeOne ip addresses are automatically refreshed every day, and nginx will be realoded when synchronization is completed.
```sh
# Auto sync ip addresses of EdgeOne and reload nginx
30 2 * * * /opt/scripts/edgeone-ip-whitelist-sync.sh >/dev/null 2>&1
```

### License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)


### DISCLAIMER
----------
Please note: all tools/ scripts in this repo are released for use "AS IS" **without any warranties of any kind**,
including, but not limited to their installation, use, or performance.  We disclaim any and all warranties, either 
express or implied, including but not limited to any warranty of noninfringement, merchantability, and/ or fitness 
for a particular purpose.  We do not warrant that the technology will meet your requirements, that the operation 
thereof will be uninterrupted or error-free, or that any errors will be corrected.

Any use of these scripts and tools is **at your own risk**.  There is no guarantee that they have been through 
thorough testing in a comparable environment and we are not responsible for any damage or data loss incurred with 
their use.

You are responsible for reviewing and testing any scripts you run *thoroughly* before use in any non-testing 
environment.
