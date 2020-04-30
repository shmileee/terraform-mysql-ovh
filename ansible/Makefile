ANSIBLE_DEFAULT_INVENTORY?="./inventories/csb/openstack.yml"
ANSIBLE_DEFAULT_PRIVATE_KEY?="~/.ssh/id_rsa"
SSH_USER?="ubuntu"

.PHONY: deploy
deploy:
	python3 -m pipenv run ansible-playbook -i $(ANSIBLE_DEFAULT_INVENTORY) --user $(SSH_USER) --private-key $(ANSIBLE_DEFAULT_PRIVATE_KEY) --vault-password-file ~/.vault playbooks/site.yml

.PHONY: deps
deps:
	ansible-galaxy install -r requirements.yml

.PHONY: clean
clean:
	ansible-galaxy list | grep -v 'unknown version' | grep -o -P '(?<=-).*(?=,)' | xargs -I '{}' ansible-galaxy remove {}


