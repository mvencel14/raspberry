#!/bin/bash

docker run --name=unbound-rpi --publish=5335:53/udp --publish=5335:53/tcp --restart=unless-stopped --detach=true mvance/unbound-rpi:latest