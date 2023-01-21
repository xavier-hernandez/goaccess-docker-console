# GoAccess for Nginx Proxy Manager Logs - Console Version

## PLEASE NOTE! - This code will open a terminal via a browser with the ability to interact with it; no security and root access to the docker container. Enough said.

<br/>
I created this to see if it was possible so expect bugs/problems.
<br/><br/>
There is flag to set the web terminal to be read only but you really lose all of the functionality of GoAccess so I didn't include it.
<br/><br/>

![Alt text](https://i.ibb.co/wwr2GCh/screenshot-1.png "GoAccess Console")

**Dependencies:**
- Gotty 1.5 (https://github.com/yudai/gotty)
- GoAccess version: 1.7
- GeoLite2-City.mmdb  (2023-01-12)
- GeoLite2-Country.mmdb  (2023-01-12)
- GeoLite2-ASN.mmdb  (2023-01-12)

---

## **Docker**
- Image: https://hub.docker.com/r/xavierh/goaccess-docker-console
- OS/ARCH
  - linux/amd64
  - linux/arm/v7
  - linux/arm64/v8
- Tags: https://hub.docker.com/r/xavierh/goaccess-docker-console/tags
  - stable version: xavierh/goaccess-docker-console:latest
  - latest stable development version: xavierh/goaccess-docker-console:develop


## **Github Repo**   
- https://github.com/xavier-hernandez/goaccess-docker-console

---


```yml
version: '3.3'
services:
    goaccess_console:
        image: 'xavierh/goaccess-docker-console:latest'
        container_name: goaccess_docker_console
        restart: always
        ports:
            - '7881:7881'
        environment:
            - TZ=America/New_York         
            - SKIP_ARCHIVED_LOGS=False #optional
            #optional   
            - EXCLUDE_IPS=127.0.0.1 #optional - comma delimited 
        volumes:
            - /path/to/host/nginx/logs:/opt/log
```
If you have permission issues, you can add PUID and PGID with the correct user id that has read access to the log files.
```yml
version: '3.3'
services:
    goaccess_console:
        image: 'xavierh/goaccess-docker-console:latest'
        container_name: goaccess_docker_console
        restart: always
        ports:
            - '7881:7881'
        environment:
            - PUID=0
            - PGID=0
            - TZ=America/New_York         
            - SKIP_ARCHIVED_LOGS=False #optional
            #optional   
            - EXCLUDE_IPS=127.0.0.1 #optional - comma delimited 
        volumes:
            - /path/to/host/nginx/logs:/opt/log
```

| Parameter | Function |
|-----------|----------|
| `-e SKIP_ARCHIVED_LOGS=True/False`         |   (Optional) Defaults to False. Set to True to skip archived logs, i.e. proxy-host*.gz     |
| `-e EXCLUDE_IPS=`         |   (Optional) IP Addresses or range of IPs delimited by comma refer to https://goaccess.io/man. For example: 192.168.0.1-192.168.0.100 or 127.0.0.1,192.168.0.1-192.168.0.100   |



# **LOG FORMATS**
### NPM PROXY LOG FORMAT
```
time-format %T
date-format %d/%b/%Y
log_format [%d:%t %^] %^ %^ %s - %m %^ %v "%U" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] "%u" "%R"
```

# **Disclaimer** 
This product includes GeoLite2 data created by MaxMind, available from
<a href="https://www.maxmind.com">https://www.maxmind.com</a>.