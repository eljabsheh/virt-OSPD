#!/bin/bash
rsync -avcP --exclude=update.sh --exclude=pull_playbooks.sh --exclude=push_all.sh --exclude=push_playbooks.sh root@198.154.189.185:/root/ansible/ .

