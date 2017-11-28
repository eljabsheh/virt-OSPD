#!/bin/bash
for myip in $(cat floatings.txt)
do
	ssh-copy-id root@${myip}
	rsync -avcP --exclude=update.sh --exclude=pull_playbooks.sh --exclude=push_all.sh --exclude=push_playbooks.sh . root@${myip}:/root/ansible
done

