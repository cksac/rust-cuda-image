#!/usr/bin/env bash

set -o pipefail

echo "Pod started.."

if [[ $PUBLIC_KEY ]]
then
  echo "Setting up SSH authorized_keys..."
  mkdir -p ~/.ssh
  echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
  chmod 700 -R ~/.ssh
  ssh-keygen -v -l -f ~/.ssh/authorized_keys
fi

echo "Regenerating SSH host keys.."
rm -f /etc/ssh/ssh_host_* && ssh-keygen -A

for SSH_HOST_PUB_KEY in /etc/ssh/ssh_host_*.pub
do
  echo "Host key: $SSH_HOST_PUB_KEY"
  ssh-keygen -lf $SSH_HOST_PUB_KEY
done

service ssh start

sleep infinity
