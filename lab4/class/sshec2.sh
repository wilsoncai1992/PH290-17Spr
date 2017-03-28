#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------
# NOTE: Requires first installing AWS Command Line Interface at:
# http://aws.amazon.com/cli/
# -------------------------------------------------------------------------------------------------------------------
# describes all recent instances:
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceType, InstanceId, PublicIpAddress]' --output table
# this will work only if there is one actively running instance:
host=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`][PublicIpAddress]' --output text)
echo $host
ssh -i "wcai-key-pair-uswest2.pem" ubuntu@$host

