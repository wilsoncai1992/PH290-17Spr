#!/bin/bash
# echo "running set-up script."

# -------------------------------------------------------------------------------------------------------------------
# Requires first installing AWS Command Line Interface at:
# http://aws.amazon.com/cli/
# -------------------------------------------------------------------------------------------------------------------

# examples using CLI:
# instance_id=$(aws ec2 run-instances --key $USER --image-id ami-f57b8f9e \
#   --instance-type t2.micro --output text --query 'Instances[*].InstanceId')
# host=$(aws ec2 describe-instances --instance-ids $instance_id \
#   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')

# describes all recent instances:
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceType, InstanceId, PublicIpAddress]' --output table

# this will work only if there is one actively running instance:
host=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`][PublicIpAddress]' --output text)
echo $host

# -------------------------------------------------------------------------------------------------------------------
# *) copy install script files:
# -------------------------------------------------------------------------------------------------------------------
scp -i ./wcai-key-pair-uswest2.pem -o StrictHostKeyChecking=no _setup1_ubuntu.sh ubuntu@$host:
scp -i ./wcai-key-pair-uswest2.pem -o StrictHostKeyChecking=no _setup2_R.R ubuntu@$host:

# -------------------------------------------------------------------------------------------------------------------
# *) to directly ssh into remote server:
# -------------------------------------------------------------------------------------------------------------------
# ssh ubuntu@$host

# -------------------------------------------------------------------------------------------------------------------
# *) remotely install ubuntu software (including R & R studio server)
# -------------------------------------------------------------------------------------------------------------------
ssh -i ./wcai-key-pair-uswest2.pem ubuntu@$host 'sudo /home/ubuntu/_setup1_ubuntu.sh'

# -------------------------------------------------------------------------------------------------------------------
# *) remotely install R packages
# -------------------------------------------------------------------------------------------------------------------
ssh -i ./wcai-key-pair-uswest2.pem ubuntu@$host 'sudo /home/ubuntu/_setup2_R.R'