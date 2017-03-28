#!/bin/bash
# -------------------------------------------------------------------------------------------------------------------
# run locally to automatically open R studio server in a new chrome browser window
# -------------------------------------------------------------------------------------------------------------------
# get host IP address for the latest instance:
host=$(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
# Open R studio server:
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --new-window $host:8787

# -------------------------------------------------------------------------------------------------------------------
# to directly access the rstudio-server interface:
# -------------------------------------------------------------------------------------------------------------------
# http://ip_address:8787

# -------------------------------------------------------------------------------------------------------------------
# To directly ssh:
# -------------------------------------------------------------------------------------------------------------------
# ssh ubuntu@$host

# -------------------------------------------------------------------------------------------------------------------
# working with aws CLI (command line tool)
# -------------------------------------------------------------------------------------------------------------------
# get instance ID for latest started instance:
# aws ec2 describe-instances --output text --query 'Reservations[0].Instances[*].InstanceId'
# get DNS address:
# aws ec2 describe-instances --output text --query 'Reservations[0].Instances[*].PublicDnsName'
# get IP address:
# aws ec2 describe-instances --output text --query 'Reservations[0].Instances[*].PublicIpAddress'
# to open new chrome window with any type of page:
# /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome 'github.com'

# -------------------------------------------------------------------------------------------------------------------
# See the list of already installed R packages:
# -------------------------------------------------------------------------------------------------------------------
# installed.packages()
