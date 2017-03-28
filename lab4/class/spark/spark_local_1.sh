#!/bin/bash
# echo "running set-up script."



aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceType, InstanceId, PublicIpAddress]' --output table
host=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`][PublicIpAddress]' --output text)
echo $host
# Run on own machine
cd /Users/wilsoncai/Desktop/Big\ data\ course/3_AWS/wilson/
# export AWS_IP=52.32.111.93
scp -i wcai-key-pair-uswest2.pem ./wilson.boto ubuntu@$host:~/.
scp -i wcai-key-pair-uswest2.pem ./wcai-key-pair-uswest2.pem ubuntu@$host:~/.ssh/

# SSH onto configure node
# ssh -i ./wcai-key-pair-uswest2.pem ubuntu@$host

# -------------------------------------------------------------------------------------------------------------------
# *) copy install script files:
# -------------------------------------------------------------------------------------------------------------------
# chmod +x ./spark/spark_local_1.sh
# chmod +x ./spark/_spark_on_configure_node.sh
scp -i ./wcai-key-pair-uswest2.pem -o StrictHostKeyChecking=no ./spark/_spark_on_configure_node.sh ubuntu@$host:
# scp -i ./wcai-key-pair-uswest2.pem -o StrictHostKeyChecking=no _setup2_R.R ubuntu@$host:
# -------------------------------------------------------------------------------------------------------------------
# *) remotely install Spark
# -------------------------------------------------------------------------------------------------------------------
ssh -i ./wcai-key-pair-uswest2.pem ubuntu@$host 'sudo /home/ubuntu/_spark_on_configure_node.sh'




