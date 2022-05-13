---
layout: single
title: "Setting Up a Local Test Bed for SlideRule Development"
date: 2022-04-01 11:35:14 -0400
toc: true
toc_sticky: true
category: developer
---

In order to test SlideRule on your local system, you need to run a reverse proxy so that processing requests that come over port 80 can be routed to the service's correct port.  Once set up, you will be able to access Grafana at `granafa.localhost`, the voila demo at `voila.localhost`, the sliderule website at `localhost`, and the sliderule server at `127.0.0.1`.

To install nginx:
```bash
$ sudo apt install nginx
```

To start|stop|restart nginx after reconfiguration:
```bash
$ sudo systemctl start|stop|restart nginx
```

To configure nginx, cut and paste the following into the default file found at `/etc/nginx/sites-enabled/default`, deleting everything else in the file.  Or remove the `default` file and replace it with a file called anything you like with the contents below. 

```yaml
# Voila
server {
    listen 80;
    server_name voila.*;
    proxy_buffering off;
    location / {
        proxy_pass http://localhost:8866/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }

    client_max_body_size 100M;
}

# Grafana
server {
    listen 80;
    server_name grafana.*;

    location / {
        proxy_set_header Host $http_host;
        proxy_pass http://localhost:3000/;
    }

    # Proxy Grafana Live WebSocket connections.
    location /api/live {
        rewrite  ^/(.*)  /$1 break;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
        proxy_pass http://localhost:3000/;
    }
}

# IP Based Routes
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # SlideRule
    location /source/ {
        proxy_set_header Host $http_host;
        proxy_pass http://localhost:9081/source/;
    }

    # Orchestrator
    location /discovery/ {
        proxy_set_header Host $http_host;
        proxy_pass http://localhost:8050;
    }

    # Jekyll
    location / {
        proxy_set_header Host $http_host;
        proxy_pass http://localhost:4000/;
    }
}
```