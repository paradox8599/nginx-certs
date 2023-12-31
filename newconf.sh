#!/bin/sh
# $1 domain name
# $2 container's network name and port

[ -z "$1" ] || [ -z "$2" ] && echo 'Usage: newconf <domain name> <container_host:port>' && exit

# Generate file if not exists
if [[ ! -f nginx.conf ]]; then
  echo '
server {
  listen 80;
  listen [::]:80;
  server_tokens off;

  location / {
    return 301 https://$host$request_uri;
  }
}
' >nginx.conf
fi

# # Check if config for the domain alreay exists
cat nginx.conf | grep "server_name $1" >/dev/null && echo "Domain $1 already exists" && exit
cat nginx.conf | grep "http://$2" >/dev/null && echo "Server $2 already exists" && exit

# Insert server config
echo '
server {
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name '$1';
  server_tokens off;

  ssl_certificate /etc/letsencrypt/live/'$1'/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/'$1'/privkey.pem;

  location / {
    proxy_pass http://'$2';
  }
}
' >>nginx.conf
