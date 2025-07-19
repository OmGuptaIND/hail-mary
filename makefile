.PHONY: install clean requirements create-user bootstrap ping prechecks

install:
	@echo ">>> Installing dependencies using uv..."
	@uv pip sync pyproject.toml
	@echo ">>> Setup complete. Dependencies installed."

# Create stack user and bridge interface
create-user:
	@echo ">>> Setting up stack user..."
	@ansible-playbook -i playbooks/create-user/inventory.ini playbooks/create-user/setup_user.yml

create-bridge:
	@echo ">>> Creating bridge interface..."
	@ansible-playbook -i playbooks/create-bridge/inventory.ini playbooks/create-bridge/setup_bridge.yml


# Kolla Ansible playbook tasks
ping:
	@echo ">>> Pinning Services"
	@ansible -i kolla-configs/inventory all -m ping

bootstrap:
	@echo ">>> Bootstrapping Kolla Ansible"
	@kolla-ansible bootstrap-servers --configdir /workspaces/hail-mary/kolla-configs/etc/kolla -i /workspaces/hail-mary/kolla-configs/inventory

prechecks:
	@echo ">>> Running prechecks"
	@kolla-ansible prechecks --configdir /workspaces/hail-mary/kolla-configs/etc/kolla -i /workspaces/hail-mary/kolla-configs/inventory

deploy:
	@echo ">>> Deploying Kolla Ansible"
	@kolla-ansible deploy --configdir /workspaces/hail-mary/kolla-configs/etc/kolla -i /workspaces/hail-mary/kolla-configs/inventory -vvv

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