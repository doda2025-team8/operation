#!/bin/bash

# Step 1: Bring up the VM without provisioning
echo "Bringing up the VM without provisioning..."
vagrant up --no-provision

# Step 2: Run provisioning manually
echo "Running Vagrant provision..."
vagrant provision

echo "Provisioning process complete."

#Step 3: Join workers
vagrant ssh ctrl
cd /vagrant
ansible-playbook playbooks/node.yaml