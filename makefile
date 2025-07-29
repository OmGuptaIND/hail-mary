.PHONY: install gen-passwords clean requirements create-user create-bridge bootstrap ping prechecks redeploy destroy

install:
	@echo ">>> Installing dependencies using uv..."
	@uv pip install git+https://opendev.org/openstack/kolla-ansible@stable/2025.1
	@uv pip sync pyproject.toml
	@echo ">>> Setup complete. Dependencies installed."

# Create stack user and bridge interface
create-user:
	@echo ">>> Setting up stack user..."
	@ansible-playbook -i /root/hail-mary/playbooks/create-user/inventory.ini /root/hail-mary/playbooks/create-user/setup_user.yml -vvv

create-bridge:
	@echo ">>> Creating bridge interface..."
	@ansible-playbook -i /root/hail-mary/playbooks/create-bridge/inventory.ini /root/hail-mary/playbooks/create-bridge/setup_bridge.yml --limit control -vvv

gen-passwords:
	@echo ">>> Generating passwords..."
	@kolla-genpwd -p /root/hail-mary/kolla-configs/passwords.yml


# Kolla Ansible playbook tasks
ping:
	@echo ">>> Pinging Services"
	@ansible -i playbooks/ping/inventory.ini all -m ping

bootstrap:
	@echo ">>> Bootstrapping Kolla Ansible"
	@kolla-ansible bootstrap-servers --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvv

prechecks:
	@echo ">>> Running prechecks"
	@kolla-ansible prechecks --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvv

deploy:
	@echo ">>> Deploying Kolla Ansible"
	@kolla-ansible deploy --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvv

reconfigure:
	@echo ">>> Reconfiguring Kolla Ansible"
	@kolla-ansible reconfigure --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini --tags nova -vvv

post-deploy:
	@echo ">>> Running post-deploy tasks"
	@kolla-ansible post-deploy --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvv

redeploy:
	@echo ">>> Re-deploying Kolla Ansible"
	@kolla-ansible deploy --tags openvswitch --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvv

destroy:
	@echo ">>> Destroying Kolla Ansible deployment"
	@kolla-ansible destroy --yes-i-really-really-mean-it --tags openvswitch --configdir /root/hail-mary/kolla-configs/etc/kolla -i /root/hail-mary/kolla-configs/inventory.ini -vvv

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