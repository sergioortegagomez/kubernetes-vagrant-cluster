Vagrant.configure("2") do |config|
  
  # K8s Master
  config.vm.define "k8s-master" do |master|
    master.vm.box = "debian/jessie64"
    master.vm.network "private_network", ip: "192.168.10.10"
    master.vm.hostname = "k8s-master"    
    master.vm.provision :shell, path: "deploy/deploy.sh"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
      vb.name = "k8s-master"
    end
  end
  
  # K8s Nodes
  (1..5).each do |i|
    config.vm.define "k8s-node-#{i}" do |node|
      node.vm.box = "debian/jessie64"
      node.vm.network "private_network", ip: "192.168.10.#{i + 10}"
      node.vm.hostname = "k8s-node-#{i}"
      node.vm.provision :shell, path: "deploy/deploy.sh"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = "4"
        vb.name = "k8s-node-#{i}"
      end
    end
  end

end
