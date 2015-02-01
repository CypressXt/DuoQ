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

  location / {
    proxy_pass http://DuoQ; # match the name of upstream directive which is defined above
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location ~* ^/assets/ {
    # Per RFC2616 - 1 year maximum expiry
    expires 1y;
    add_header Cache-Control public;

    # Some browsers still send conditional-GET requests if there's a
    # Last-Modified header or an ETag header even if they haven't
    # reached the expiry date sent in the Expires header.
    add_header Last-Modified "";
    add_header ETag "";
    break;
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
