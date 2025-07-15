#!/bin/bash

pass="$1"

echo $pass | sudo -S touch /etc/sudoers.d/10-SUDOERS
echo $pass | sudo chmod 666 /etc/sudoers.d/10-SUDOERS
echo $pass | sudo -S echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/10-SUDOERS
echo $pass | sudo -S echo "%grp-asp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/10-SUDOERS
echo $pass | sudo chmod 0440 /etc/sudoers.d/10-SUDOERS
