# Run on own machine
export AWS_IP=52.38.19.76
scp -i ./wcai-key-pair-uswest2.pem ./wilson.boto ubuntu@${AWS_IP}:~/.
scp -i ./wcai-key-pair-uswest2.pem ./wcai-key-pair-uswest2.pem ubuntu@${AWS_IP}:~/

ssh -i ./wcai-key-pair-uswest2.pem ubuntu@${AWS_IP}
# ================================================================================
# On AWS
wget http://d3kbcqa49mib13.cloudfront.net/spark-1.5.1.tgz
tar -xzf spark-1.5.1.tgz
# --------------------------------------------------------------------------------
export AWS_ACCESS_KEY_ID=`grep aws_access_key_id wilson.boto | cut -d' ' -f3`
export AWS_SECRET_ACCESS_KEY=`grep aws_secret_access_key wilson.boto | cut -d' ' -f3`

# mv ./wcai-key-pair-uswest2.pem ~/.ssh/
chmod 400 ./wcai-key-pair-uswest2.pem
# --------------------------------------------------------------------------------
cd ./spark-1.5.1/ec2
# --------------------------------------------------------------------------------
export NUMBER_OF_WORKERS=3
# export NUMBER_OF_WORKERS=12
./spark-ec2 -k wcai-key-pair-uswest2 -i ~/wcai-key-pair-uswest2.pem --region=us-west-2 -s ${NUMBER_OF_WORKERS} -v 1.5.1 launch sparkvm-wcai

# --------------------------------------------------------------------------------
# Login SPARK
./spark-ec2 -k wcai-key-pair-uswest2 -i ~/wcai-key-pair-uswest2.pem --region=us-west-2 login sparkvm-wcai
# --------------------------------------------------------------------------------
# Log-on to slave
# ssh `head -n 1 /root/ephemeral-hdfs/conf/slaves`

# you can check your nodes via the EC2 management console
# to logon to one of the slaves, look at /root/ephemeral-hdfs/conf/slaves
# and ssh to that address
ssh `head -n 1 /root/ephemeral-hdfs/conf/slaves`

# We can view system status through a web browser interface
# on master node of the EC2 cluster, do:
MASTER_IP=`cat /root/ephemeral-hdfs/conf/masters`
echo ${MASTER_IP}

# Point a browser on your own machine to the result of the next command
# you'll see info about the "Spark Master", i.e., the cluster overall
echo "http://${MASTER_IP}:8080/"

# Point a browser on your own machine to the result of the next command
# you'll see info about the "Spark Stages", i.e., the status of Spark tasks
echo "http://${MASTER_IP}:4040/"

# Point a browser on your own machine to the result of the next command
# you'll see info about the HDFS"
echo "http://${MASTER_IP}:50070/"
# --------------------------------------------------------------------------------
export PATH=$PATH:/root/ephemeral-hdfs/bin/

# -----------
# load airline file
hadoop fs -mkdir /data
hadoop fs -mkdir /data/airline
# hadoop fs -rmr /data
# hadoop fs -rm /data/airline
# hadoop fs -mkdir /mnt
# hadoop fs -mkdir /mnt/airline
df -h

## Download files and unzip
wget https://www.ocf.berkeley.edu/~wcai/share/spark/1987-2008.csvs.tgz
tar zxvf 1987-2008.csvs.tgz
hadoop fs -copyFromLocal ~/*bz2 /data/airline
hadoop fs -ls /data/airline
# -----------

yum install python27-pip python27-devel
pip-2.7 install 'numpy==1.9.2'
# Install numpy on all slaves
/root/spark-ec2/copy-dir /usr/local/lib64/python2.7/site-packages/numpy
# Start Spark's Python interface as interactive session
export PATH=${PATH}:/root/spark/bin
pyspark
# ================================================================================
# To EXIT
./spark-ec2 --region=us-west-2 --delete-groups destroy sparkvm-wcai

# To preserve instance
screen -x -RR
# --------------------------------------------------------------------------------