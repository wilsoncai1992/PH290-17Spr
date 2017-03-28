#!/bin/bash
echo "running set-up script."

# -------------------------------------------------------------------------------------------------------------------
# add ubuntu to staff user to be able to install R packages to default location:
# -------------------------------------------------------------------------------------------------------------------
sudo adduser ubuntu staff

# -------------------------------------------------------------------------------------------------------------------
# install a bunch of ubuntu software
# -------------------------------------------------------------------------------------------------------------------
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo add-apt-repository 'deb  http://cran.stat.ucla.edu/bin/linux/ubuntu trusty/'
sudo apt-get update
sudo apt-get -y install r-base-core             # R
sudo apt-get -y install lrzsz                   # a tool for remote file transfer:
sudo apt-get -y install libcurl4-openssl-dev    # for RCurl which devtools depends on
sudo apt-get -y install libxml2-dev             # needed for devtools
sudo apt-get -y install htop                    # to monitor RAM and CPU
sudo apt-get install gdebi-core -y              # compiler for installing Rstudio Server
wget https://download2.rstudio.org/rstudio-server-0.99.489-amd64.deb # Rstudio Server
sudo gdebi rstudio-server-0.99.489-amd64.deb -n

# -------------------------------------------------------------------------------------------------------------------
# create a user "rstudio" w/ password "rstudio"
# -------------------------------------------------------------------------------------------------------------------
sudo adduser rstudio <<EOF
rstudio
rstudio
EOF
sudo adduser rstudio staff # add rstudio user to staff group (to install future R packages in the same location)





# -------------------------------------------------------------------------------------------------------------------
# to do first ssh:
# ssh -i "wilson.pem" ubuntu@52.89.52.134
# to run this script remotely:
# ssh -i "wilson.pem" ubuntu@52.89.52.134 '/home/ubuntu/AWSsetup/1_set_up.sh'
# -------------------------------------------------------------------------------------------------------------------
# using aws CLI (command line tool)
# -------------------------------------------------------------------------------------------------------------------
# host=$(aws ec2 describe-instances --output text --query 'Reservations[0].Instances[*].PublicIpAddress')
# This enables passwordless/serverless ssh:
# ssh ubuntu@$host
# Opening R studio right away:
# /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome $host:8787
# -------------------------------------------------------------------------------------------------------------------
# To copy single file to remote:
# -------------------------------------------------------------------------------------------------------------------
# scp -i ~/wilson.pem localFile.csv ubuntu@52.89.52.134:
# To copy from EC2 (final space then dot is needed):
# scp -i ~/wilson_ncal.pem ubuntu@52.9.19.109:~/Malaria_sim/SEM_malaria_runN2000.pdf .
# to copy folder to remote EC2 server (final colon needed):
# scp -r -i ~/wilson.pem ~/AWSsetup ubuntu@52.9.19.109:
# scp -r -i ~/wilson.pem /Users/olegwilson/GoogleDrive/Network_TMLE/TMLENET_package/tmlenet ubuntu@52.89.52.134:
# scp -i ~/wilson.pem ~/DAGobj_reg_Kmax5_n500K.RData ubuntu@52.89.52.134:
# scp -i ~/wilson.pem ~/DAGobj_reg_Kmax5_n1MIL_newtrunc7.RData ubuntu@52.89.52.134:
# -------------------------------------------------------------------------------------------------------------------
# set up directory for R libraries (NO LONGER USED):
# -------------------------------------------------------------------------------------------------------------------
# mkdir ~/R
# mkdir ~/R/library
# export R_LIBS_USER=~/R/library
# echo "export R_LIBS_USER=~/R/library" >> ~/.profile
# -------------------------------------------------------------------------------------------------------------------
# to set up default password for ubuntu user (NO LONGER USED):
# -------------------------------------------------------------------------------------------------------------------
# sudo passwd <<EOF
# ubuntu
# ubuntu
# EOF
# same, but remotely
# ssh -i "wilson.pem" ubuntu@52.89.52.134 'sudo passwd <<EOF
# ubuntu
# ubuntu
# EOF';
# -------------------------------------------------------------------------------------------------------------------
# list all users:
# -------------------------------------------------------------------------------------------------------------------
# cut -d: -f1 /etc/passwd
# add new users:
# sudo adduser rstudio
# change existing users password:
# passwd rstudio


