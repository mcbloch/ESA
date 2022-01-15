# Alternative oss boxes: https://app.vagrantup.com/bento

# groups with ip's
# - metal                  => machine1 | vagrant   ; 
# - simple_web-container   => swc-01   | 172.0.0.1 ; 


# virtual groups
# - simple_web -> simple_web-container, 
# - container -> simple_web-container, 


Vagrant.configure("2") do |config|

  config.vm.define "machine1"
  #  
  # Run Ansible from the Vagrant Host  
  #  
  config.vm.network "forwarded_port", guest: 8321, host: 8321
  config.vm.network "forwarded_port", guest: 8322, host: 8322

  config.vm.box = "bento/debian-10.11"
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.groups = {
      "metal" => ["machine1"],
      #"simple_web" => ["simple_web-container"],
      #"container" => ["simple_web-container"],
    }
    # ansible.verbose = "vvv"
    # ansible.tags = "network"
  end
end