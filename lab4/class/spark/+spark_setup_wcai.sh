cd /Users/wilsoncai/Desktop/Big\ data\ course/3_AWS/wilson/
# chmod +x ./spark/spark_local_1.sh
./spark/spark_local_1.sh

# --------------------------------------------------------------------------------
# Log-on to slave
# ssh `head -n 1 /root/ephemeral-hdfs/conf/slaves`
# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# On Spark master node
export PATH=$PATH:/root/ephemeral-hdfs/bin/

yum install python27-pip python27-devel
pip-2.7 install 'numpy==1.9.2'
# Install numpy on all slaves
/root/spark-ec2/copy-dir /usr/local/lib64/python2.7/site-packages/numpy
export PATH=${PATH}:/root/spark/bin
pyspark

# ================================================================================
# To EXIT; run on "configure node"
./spark-ec2 --region=us-west-2 --delete-groups destroy sparkvm-wcai



# ---------------
# To preserve instance
screen
# DO normally, and when internet will break
Ctrl + a + d # DETACH 
screen -x -RR # RECONNECT
# --------------------------------------------------------------------------------
