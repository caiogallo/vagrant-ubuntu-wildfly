# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.hostname = "windfly"

  # Provider-specific configuration so you can fine-tune various backing
  # providers for Vagrant. These expose provider-specific options.
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM
    vb.customize ["modifyvm", :id,
                  "--name", "windfly",
                  "--memory", "1024"]
  end

  config.vm.provision :shell, :inline => "echo \"America/Brazil\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  config.vbguest.auto_update = false

  config.vm.provision :puppet do |puppet|
	puppet.manifests_path = "manifests"
	puppet.manifest_file = "default.pp"
	puppet.module_path = "manifests/modules"
	puppet.options = "--verbose"
  end 

end
