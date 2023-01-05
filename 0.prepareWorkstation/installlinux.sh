#!/bin/bash
echo -e '

#   ____  _  __ ____    _      ____  ____  _  __ ____  _     ____  ____ 
#  /  _ \/ |/ // ___\  / \  /|/  _ \/  __\/ |/ // ___\/ \ /|/  _ \/  __\
#  | / \||   / |    \  | |  ||| / \||  \/||   / |    \| |_||| / \||  \/|
#  | |-|||   \ \___ |  | |/\||| \_/||    /|   \ \___ || | ||| \_/||  __/
#  \_/ \|\_|\_\\____/  \_/  \|\____/\_/\_\\_|\_\\____/\_/ \|\____/\_/   
#                                                                       
Author: Karim Moussa
'

echo 'Installing docker...'

chmod +x ./installdocker.sh
./installdocker.sh

echo 'running SQL Server Container... '

docker run -e "ACCEPT_EULA=1" -e "MSSQL_SA_PASSWORD=MyPass@word" -e "MSSQL_PID=Developer" -e "MSSQL_USER=SA" -p 1433:1433 -d --platform linux/arm64/v8 --name=sql mcr.microsoft.com/azure-sql-edge

echo 'install SQLCMD'

sudo su

curl https://packages.microsoft.com/config/rhel/8/prod.repo > /etc/yum.repos.d/msprod.repo
exit

sudo yum remove mssql-tools unixODBC-utf16-devel
sudo yum install mssql-tools unixODBC-devel

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

#ubuntu

curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

sudo apt-get update 
sudo apt-get install mssql-tools unixodbc-dev

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc




echo 'Installing Kind...'
#curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
#chmod +x ./kind
#sudo mv ./kind /usr/local/bin/kind

echo 'Kind is installed.'