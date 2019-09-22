Vagrant.configure("2") do |config|
  
  #Hardware configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "2"
  end

  # K8s Master
  config.vm.define "k8s-master" do |master|
    master.vm.box = "debian/jessie64"
    master.vm.network "private_network", ip: "192.168.10.10"
    master.vm.hostname = "k8s-master"
    master.vm.provision :shell, path: "deploy/deploy.sh"
  end
  
  # K8s Nodes
  (1..5).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "debian/jessie64"
      node.vm.network "private_network", ip: "192.168.10.#{i + 10}"
      node.vm.hostname = "k8s-node-#{i}"
      node.vm.provision :shell, path: "deploy/deploy.sh"
    end
  end

end
