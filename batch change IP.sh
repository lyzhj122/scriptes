ssh-keygen -f  /root/.ssh/id_rsa -P ' '
NET=192.168.1
export SSHPAS=user
for IP in {1..200}; do
  sshpass -e ssh-copy-id $NET.$IP
done
