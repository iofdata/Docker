#!/bin/bash

#create admin account to memcached using SASL
#memcached -u root -S  -l 0.0.0.0
#memcached -d -c 10240 -m 1600 -u root
/usr/local/bin/memcached -u root -d -c 10240
