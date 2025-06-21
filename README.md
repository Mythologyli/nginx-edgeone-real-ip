# 在使用 Nginx 和 EdgeOne 时获取访客真实 IP 地址

[English](README_en.md)

本项目基于 [nginx-cloudflare-real-ip](https://github.com/ergin/nginx-cloudflare-real-ip) 修改而来，感谢原作者 [ergin](https://github.com/ergin)

----

修改 nginx 配置，使 Web 应用（位于 EdgeOne 后）访客真实 IP 地址。提供 Bash 脚本定期更新 EdgeOne IP 列表文件。

为了在每个请求中向源服务器提供访问者的 IP 地址，EdgeOne 会添加 "EO-Connecting-IP" 请求头。可以捕获该请求头，从而获取真实 IP 地址。

## Nginx 配置
打开 "/etc/nginx/nginx.conf" 文件，并在 http{....} 块中添加以下配置：

```nginx
include /etc/nginx/edgeone;
```

可以手动运行 Bash 脚本，也可以通过计划任务自动刷新 EdgeOne 的 IP 地址列表。
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

## 输出
得到的 "/etc/nginx/edgeone" 文件如下所示：

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

EdgeOne 的 IP 地址会每天自动刷新，在同步完成后，将重新加载 Nginx。
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
