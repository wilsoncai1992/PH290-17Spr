# set -o shwordsplit
# ================================================================================
# export aws_account_id=933882143021
# https://933882143021.signin.aws.amazon.com/console/

# Run once
# keypair=$USER
# publickeyfile=$HOME/.ssh/id_rsa.pub
# regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
# for region in $regions; do
#   echo $region
#   aws ec2 import-key-pair --region "$region" --key-name "$keypair" --public-key-material "file://$publickeyfile"
# done
# chmod 400 wcai-key-pair-uswest2.pem
# ================================================================================
# On own machine
export AWS_IP=54.149.230.27
ssh -i "wcai-key-pair-uswest2.pem" ubuntu@${AWS_IP} # to ssh onto AWS

# chmod +x ./_setup1_ubuntu.sh
# chmod +x ./_setup2_R.R
# chmod +x ./0_run_remote_setup.sh
# chmod +x ./1_open_Rstudio.sh 
./0_run_remote_setup.sh # to configure AWS machine
./1_open_Rstudio.sh # to run RStudio in browser

# ssh into AWS machine
chmod +x ./sshec2.sh
./sshec2.sh 
# ================================================================================
# on AWS

# ================================================================================
# To copy to EC2 (final colon needed):
# scp localFile.csv ubuntu@${AWS_IP}:

# To copy from EC2 (final space then dot is needed):
# scp ubuntu@${AWS_IP}:~/remoteFile.csv .