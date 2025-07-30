.PHONY: install gen-passwords clean requirements create-user create-bridge bootstrap ping prechecks redeploy destroy

install:
	@echo ">>> Installing dependencies using uv..."
	@uv pip sync pyproject.toml
	@uv pip install git+https://opendev.org/openstack/kolla-ansible@stable/2025.1
	@kolla-ansible --version
	@kolla-ansible install-deps
	@echo ">>> Setup complete. Dependencies installed."

ssh-control:
	@echo ">>> SSH into control node..."
	@ssh -i /root/hail-mary/keys/root root@10.180.220.19

ssh-compute:
	@echo ">>> SSH into compute node..."
	@ssh -i /root/hail-mary/keys/root root@10.180.220.6

# Create stack user and bridge interface
create-user:
	@echo ">>> Setting up stack user..."
	@ansible-playbook -i /root/hail-mary/playbooks/create-user/inventory.ini /root/hail-mary/playbooks/create-user/setup_user.yml -vvvv

create-bridge:
	@echo ">>> Creating bridge interface..."
	@ansible-playbook -i /root/hail-mary/playbooks/create-bridge/inventory.ini /root/hail-mary/playbooks/create-bridge/setup_bridge.yml --limit control -vvvv

gen-passwords:
	@echo ">>> Generating passwords..."
	@kolla-genpwd -p /root/hail-mary/kolla-configs/etc/kolla/passwords.yml


# Kolla Ansible playbook tasks
ping:
	@echo ">>> Pinging Services"
	@ansible -i playbooks/ping/inventory.ini all -m ping

pull:
	@echo ">>> Pulling Kolla Ansible images"
	@kolla-ansible pull --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvvv

bootstrap:
	@echo ">>> Bootstrapping Kolla Ansible"
	@kolla-ansible bootstrap-servers --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvvv

prechecks:
	@echo ">>> Running prechecks"
	@kolla-ansible prechecks --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvvv

deploy:
	@echo ">>> Deploying Kolla Ansible"
	@kolla-ansible deploy --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini

reconfigure:
	@echo ">>> Reconfiguring Kolla Ansible"
	@kolla-ansible reconfigure --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini --tags nova -vvvv

post-deploy:
	@echo ">>> Running post-deploy tasks"
	@kolla-ansible post-deploy --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvvv

redeploy:
	@echo ">>> Re-deploying Kolla Ansible"
	@kolla-ansible deploy --tags openvswitch --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvvv

destroy:
	@echo ">>> Destroying Kolla Ansible deployment"
	@kolla-ansible destroy --yes-i-really-really-mean-it --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvvv

## Remove cache files
clean: 
	@echo ">>> Cleaning cache files..."
	@find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete


requirements:
	@echo ">>> Generating requirements.txt..."
	@uv pip compile pyproject.toml --generate-hashes -o requirements.txt


# Fix the locale issue
# export LC_ALL=C.UTF-8
# export LANG=C.UTF-8

# # Make it permanent for the session
# echo "export LC_ALL=C.UTF-8" >> ~/.bashrc
# echo "export LANG=C.UTF-8" >> ~/.bashrc
# source ~/.bashrc

# # Install locale support
# apt-get update
# apt-get install -y locales
# locale-gen en_US.UTF-8

# watch -n 10 'ssh -i /workspaces/hail-mary/keys/compute/stack stack@51.75.52.8 "sudo docker ps --format \"table {{.Names}}\t{{.Status}}\""'

# Set proper permissions for the SSH keys
# chmod 600 /workspaces/hail-mary/keys/controller/stack
# chmod 600 /workspaces/hail-mary/keys/compute/stack

# # If you have .pub files, set them to 644
# chmod 644 /workspaces/hail-mary/keys/controller/stack.pub 2>/dev/null || true
# chmod 644 /workspaces/hail-mary/keys/compute/stack.pub 2>/dev/null || true


# Remove IP from physical interface
# sudo ip addr del 93.115.29.63/24 dev enp1s0

# # Add IP to the br-ex bridge
# sudo ip addr add 93.115.29.63/24 dev br-ex
# sudo ip link set br-ex up

# # Remove old default route
# sudo ip route del default via 93.115.29.1 dev enp1s0 | 93.115.29.1 is Gateway IP

# # Add new default route via br-ex
# sudo ip route add default via 93.115.29.1 dev br-ex

# sudo rm -f /var/lib/docker/volumes/*/var/run/openvswitch/*.pid
# # or if it's a bind mount:
# sudo rm -f /var/run/openvswitch/*.pid