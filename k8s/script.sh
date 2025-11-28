#!/bin/bash

# Step 1: Bring up the VM without provisioning
echo "Bringing up the VM without provisioning..."
vagrant up --no-provision

# Step 2: Run provisioning manually
echo "Running Vagrant provision..."
vagrant provision

echo "Provisioning process complete."

#Step 3: Join workers
echo "Joining workers..."
vagrant ssh ctrl -c "ansible-playbook /vagrant/playbooks/node.yaml"

echo "Workers joined."