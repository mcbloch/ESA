.PHONY: init, lint, format, clean, config, test, test-container

init:
	ansible-galaxy install -r requirements.yml
lint:
	ansible-lint --exclude=vagrantconfig.yaml
format:
	cd configuration && dhall format config.dhall
	cd configuration && dhall format esa.dhall
	cd configuration && dhall format types.dhall
	cd configuration && dhall format validations.dhall
clean:
	vagrant destroy
yeet:
	cd configuration && echo '(./esa.dhall)' | dhall-to-yaml
config:
	cd configuration && echo '(./esa.dhall).hostVars' | dhall-to-yaml \
			--explain \
			--documents \
			--generated-comment \
			--output ../inventory/01-esa_generated.yml
	cd configuration && echo '(./esa.dhall).ssh_config' | dhall text \
			--output ssh.config
test:
	vagrant up --provision
test-container:
	ansible-playbook simple-web.yml
	ansible-playbook ruby-web.yml