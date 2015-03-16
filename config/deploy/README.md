## Hosting
### Ngnix

#### Config file 
```
upstream DuoQ {
  server unix:///tmp/DuoQ.sock;
}

server {
  listen 80;
  server_name duoq.cypressxt.net; # change to match your URL
  root /home/cypress/www/DuoQ/current/public; # I assume your app is located at that location

  proxy_buffers 8 32k;
  proxy_buffer_size 64k;

location / {
    root              /home/cypress/www/DuoQ/current/public;
    try_files         $uri @app;
    gzip_static       on;
    expires           max;
    add_header        Cache-Control public;
  }

location @app {
    proxy_pass        http://duoq;
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto http;
    proxy_set_header  Host $http_host;
    proxy_redirect    off;
    proxy_next_upstream error timeout invalid_header http_502;
  }

}

```
### Puma

#### Start puma 
startPuma.sh
```
#!/bin/bash

PATH=/home/cypress/.rbenv/shims:/home/cypress/.rbenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
cd /home/cypress/www/DuoQ/current
bundle exec puma -e production -d -b unix:///tmp/DuoQ.sock
```

#### Restart puma
restartPuma.sh
```
#!/bin/bash
kill $(ps aux | grep "puma -e" | grep "ruby" | awk '{print $2}')
cd /home/cypress/
./startPuma.sh
```
