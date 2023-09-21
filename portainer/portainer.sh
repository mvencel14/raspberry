#!/bin/bash

docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v /opt/docker/portainer/portainer_data:/data portainer/portainer-ce:latest