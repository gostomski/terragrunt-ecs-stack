#!/bin/bash

# ECS config
{
  echo "ECS_CLUSTER=${cluster_name}"
} >> /etc/ecs/ecs.config

sed -i '/After=cloud-final.service/d' /usr/lib/systemd/system/ecs.service
systemctl daemon-reload

#open file descriptor for stderr
exec 2>>/var/log/ecs/ecs-agent-install.log
set -x
#verify that the agent is running
until curl -s http://localhost:51678/v1/metadata
do
	sleep 1
done
#install the Docker volume plugin
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION={aws_region} --grant-all-permissions
#restart the ECS agent
systemctl restart docker
systemctl restart ecs
echo "Done"
