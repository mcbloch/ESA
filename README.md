# ESA - Expressive Safe Ansible

An opinionated wrapper around ansible to make it hard to use incorrectly by adding good presets and handy wrappers.

Work in progress. All suggestions and comments are welcome.

## How to run current test setup

- run `make test`, this ups a vagrant host with a few lxc containers on it.
- copy the container ip's from stdout and set them in configuration/config.dhall
- run `make config` to update the generated config files
- run `make test-container` to run example ansible playbooks against the containers

## Features

- Single declarative configuration. This can be found at [configuration/config.dhall](./configuration/config.dhall)
- Easy ssh access onto the defined hosts and containers using the esa tool
  - `esa.sh simple-web-01`
- Automatic (lightweight) container setup using the single configuration file with port forwarding
- Easy to test using a provided Vagrant setup. See the section above.
- Users: Are defined globally and can be assigned to containers to get access. They will get their own user per container.

### Notes

- Only compatible with debian at the moment
- container ip's are still dynamic, see the test setup above en todo notes below

## TODO

- Retrieve IP of created container and set as dynamic variable
- Probably need to use a better dynamic hosts tool
- Use static ip's
  - Not setting the ip is possible but you are then unable to run a playbook against the host automatically. You will need to paste the ip in the inventory manually. The container is possible to get port forwards but the ssh config can not be set automatically atm. Also, all port forwards break on reboot :)

## Roadmap

- Add vault best practices
- Add a bastion user to jump through the host to containers (without shell access for the bastion)
- Run unprivileged containers
- Add ssh wrapper that adds flags to add the generated ssh.config

- Add automatic testing on filechanges
  - Check yaml validity
  - Check ansible validity
  - Try vagrant test

## Extras

- Check network bridge on host: `ip -4 -o a show`
- List lxc containers: `lxc-ls --fancy`
- Ssh to a container or host defined in the ssh.config file: `ssh -o ControlMaster=auto -o ControlPersist=30m -o ControlPath=/tmp/ansible-%r@%h:%p -F ssh.config simple-web-01`
- Check NAT rules: `iptables -L -n -t nat`
- List prerouting rules: `sudo iptables -t nat -L PREROUTING -n --line-number`
- Remove a prerouting rule `sudo iptables -t nat -D PREROUTING 1`

## More things I try to achieve

- Keep everything in the folder. No usage of external servers or heavy tools.
- 