# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider :hyperv do |vm, override|
    override.vm.box = "pyranja/centos-7"
    override.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: ENV['HOST_USER'], smb_password: ENV['HOST_SECRET']
  end

end
