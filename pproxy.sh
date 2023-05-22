#! /bin/bash 
#
# -l listen on port 8080
# -r reverse proxy to use socks5  
#

pproxy -l http://0.0.0.0:8080 -r socks5://<Proxy-Host-IP>:<Port> -v > $PWD/pproxy.log &

