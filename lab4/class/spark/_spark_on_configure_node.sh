#!/bin/bash
echo "running set-up script."

# ================================================================================
# On AWS
wget http://d3kbcqa49mib13.cloudfront.net/spark-1.5.1.tgz
tar -xzf spark-1.5.1.tgz
# --------------------------------------------------------------------------------
export AWS_ACCESS_KEY_ID=`grep aws_access_key_id wilson.boto | cut -d' ' -f3`
export AWS_SECRET_ACCESS_KEY=`grep aws_secret_access_key wilson.boto | cut -d' ' -f3`

# mv ./wcai-key-pair-uswest2.pem ~/.ssh/
chmod 400 ~/.ssh/wcai-key-pair-uswest2.pem
# --------------------------------------------------------------------------------
cd ./spark-1.5.1/ec2
# --------------------------------------------------------------------------------
export NUMBER_OF_WORKERS=3
# export NUMBER_OF_WORKERS=12
./spark-ec2 -k wcai-key-pair-uswest2 -i ~/.ssh/wcai-key-pair-uswest2.pem --region=us-west-2 -s ${NUMBER_OF_WORKERS} -v 1.5.1 launch sparkvm-wcai

# --------------------------------------------------------------------------------
# Login SPARK
./spark-ec2 -k wcai-key-pair-uswest2 -i ~/.ssh/wcai-key-pair-uswest2.pem --region=us-west-2 login sparkvm-wcai
