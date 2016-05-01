#!/bin/bash

user="builder"

echo "$@"
echo su "$user" -c "/home/$user/start.sh" $@
sleep 10
su "$user" -c "/home/$user/start.sh $@"

