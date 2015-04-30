## Hosting
### Ngnix

#### Config file 
```

upstream rails_app {
  server unix:///tmp/DuoQ.sock fail_timeout=0;
}

server {
  # listen 80 deferred;
  server_name duoq.cypressxt.net 192.168.1.106;
  root /home/cypress/www/DuoQ/current/public/;
  access_log /home/cypress/www/DuoQ/current/log/nginx.access.log;
  error_log /home/cypress/www/DuoQ/current/log/nginx.error.log info;

  try_files $uri/index.html $uri @rails_app;

  client_body_buffer_size 10K;
  client_header_buffer_size 1k;
  client_max_body_size 8m;
  large_client_header_buffers 2 1k;

  location @rails_app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;

    proxy_connect_timeout      1500;
    proxy_send_timeout         1500;
    proxy_read_timeout         1500;


    proxy_buffers 8 32k;
    proxy_buffer_size 64k;
    proxy_pass http://rails_app;
  }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires 1y;
                log_not_found off;
        }

  location /fonts {
    alias /home/cypress/www/DuoQ/current/vendor/assets/fonts;
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
bundle exec puma -e production -d -b unix:///tmp/DuoQ.sock?umask=0111
```

#### Restart puma
restartPuma.sh
```
#!/bin/bash
kill $(ps aux | grep "puma -e" | grep "ruby" | awk '{print $2}')
cd /home/cypress/
./startPuma.sh
```
