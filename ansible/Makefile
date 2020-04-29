ANSIBLE_DEFAULT_INVENTORY?="./inventory.yml"
ANSIBLE_DEFAULT_PRIVATE_KEY?="~/.ssh/id_rsa"

.PHONY: deploy
deploy: clean deps
	ansible-playbook -i $(ANSIBLE_DEFAULT_INVENTORY) --private-key $(ANSIBLE_DEFAULT_PRIVATE_KEY) playbooks/site.yml

.PHONY: deps
deps:
	ansible-galaxy install -r requirements.yml

.PHONY: clean
clean:
	ansible-galaxy list | grep -v 'unknown version' | grep -o -P '(?<=-).*(?=,)' | xargs -I '{}' ansible-galaxy remove {}


